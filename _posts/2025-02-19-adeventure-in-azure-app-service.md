---
layout: post
title:  "Adventure in Azure App Service"
categories: azure
---

## Background

Perhaps this is obvious to everyone, but in the world of deployed enterprise software, there seems to be a shift to desiring PaaS compatible options versus historically standard physical or virtual machines on either on-premise or cloud-hosted machines.

A key undercurrent that has been occurring over the past number of years (decade?) is the proliferation of SaaS software and the ease of use/maintenance/deployment vs. hosted software. With that said, I wonder if SaaS software has hit some saturation limit where some companies are starting to prefer software vendors deploying to their infrastructure of choice vs. buying another SaaS. At least in my eyes, the few reasons I can think of from direct experience:

1. Limiting trust in third parties as it relates to data security. Saying it differently, limiting the number of discreet entities that you have to implicitly trust as it relates to your data. [With that said, not all data is created equally, and not all data has equivalent outcomes on an unscheduled/unplanned public release.]
2. A step against vendor lock-in. By forcing deployment on infrastructure of your choice, you will retain management of the layer underneath the application. If data has to be stored in the infrastructure, you retain total authority of the data [minus the trust in the infrastructure vendor's security].
3. Certainty about long term *hosting* costs. I'm not a SaaS software expert, but in the absence of longer term contracts, SaaS vendors have unilateral decision making around the cost of their solution. Some of that cost will be spent on the infrastructure and the rest on the secret sauce on top. By forcing deployment onto chosen infrastructure, it may be easier to compare apples to apples since hosting cost is explicitly covered under a different arrangement.

Now, that doesn't immediately relate to why PaaS options are starting to be preferred over straight infrastructure; again, I theorize the following:

1. If you already trust the PaaS vendor, you eliminate the need to be concerned with the OS and as a result, entire classifications of malware/attack vectors as well as updates to the OS.
2. Choosing a specific set of PaaS options allows you to build substantial operational depth with that solution. In other words, the cookie cutter narrows from all possible application types and structures on a given OS to only applications that function on the specific PaaS(s).
3. Perhaps this a more subtle effect, but I've seen a relentless focus on eliminating passwords/secrets for authorization purposes. I can understand why: compromise leads to bad outcomes, and if there's no password/secret to compromise, no bad outcome is possible [for that type of compromise]. When you go all-in with a cloud platform and its managed offerings, you can opt into reasonably high security options with low effort implementations. For Azure, it's managed identities and service principals that can be integrated at the resource and PaaS level. For AWS, it's the IAM apparatus.

Again, we all know PaaS have been around for a while (i.e. Heroku), so this is nothing new. But I am getting the feeling that the elimination of certain concerns and attack vectors by using a PaaS is driving adoption even in the most "enterprise-y" of enterprise environments.

## The Problem

With all of that said, we encountered a situation where we needed to deploy our software to [Azure App Service](https://learn.microsoft.com/en-us/azure/app-service/), a PaaS that primarily handles two types of applications:

1. Native code applications written in .NET, Java, Python, etc.
2. Arbitrary containers. Docker Compose is [a *sorta* supported option](https://learn.microsoft.com/en-us/azure/app-service/configure-custom-container?tabs=debian&pivots=container-linux#use-persistent-storage-in-docker-compose).

Specifically, we had to deploy our application into the customer's tenant directly with none of our staff able to view the Azure resources from their own account. This is very much akin to handing an IT department an installer and an installation manual and then helping them when something doesn't quite go right. For those that have done this, you know the difficulty inherent to this task.

Our application was normally hosted on Linux as a collection of containers via a Docker Compose strategy, so perhaps the next question is "why not use a k8s like [AKS](https://learn.microsoft.com/en-us/azure/aks/what-is-aks) or k8s-lite option e.g. [Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/overview)?"

Unfortunately, the design of the application prevented multi-instance from working perfectly. There's only two areas that are not compatible with multi-instance, so there was a design decision early on that led us down this path because horizontal scaling was not a requirement and avoiding it simplified certain problems. For example, gRPC server streaming is a stateful connection that solves certain problems elegantly, but a stateful connection imposes a restriction on horizontal scaling if the connection is going to be a long lasting one.

So, without using a multi-instance PaaS, we decided going down the container route since it seemed the most similar to our previous model.

## First Iteration - Compose

After seeing that Compose was somewhat supported, why not pursue that option first? Well, as we would find out, there were four challenges:

1. 4000 character limit
2. No connectivity to Docker socket
3. Persistence is a complicated subject.
4. Dealbreaker - no virtual network integration.

### 4000 Characters

The 4000 character limit is surprisingly difficult to deal with in multi-container deployments. A lot of environment variables may be needed, and every line adds whitespace that is a total waste. In addition, the 4000 characters wasn't 4000 characters of a YAML file that you might expect; it's actually 4000 Base64 characters which is not 1:1 with underlying text. The solution I found was to do the following:

- Limit environment variables as much as possible
- Create container images for certain applications e.g. Traefik to "compile in" as much configuration as possible
- Docker Compose should only represent the core application. Anything that isn't strictly the application or could exist in a separate App Service, host it there. For example, Grafana does not need to be hosted alongside the other components, so deploy that as a second App Service.

### No Docker Socket

As mentioned above, the only piece of software we were using that would need the Docker socket was Traefik and its Docker configuration providers. Unfortunately, without access to the Docker socket, this not feasible. Thus, the only alternative, if you want to continue to use Traefik, is to either mount in or create an extended container containing static configuration. I chose the latter approach to minimize amount of configuration that has to be handled by the eventual Bicep file.

### Persistence is complicated

Persistence with App Service is complicated in general, but for Compose, it's doubly so. As with all App Service deployments, your two options of direct persistence are:

1. Host in the Azure App Service dedicated area i.e. /home or `WEBAPP_STORAGE_HOME`. This is not extremely well documented and the size is set by the [tier of your App Service Plan](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#app-service-limits)
2. Host in Azure Files. According to the [official docs](https://learn.microsoft.com/en-us/azure/app-service/configure-connect-to-azure-storage?tabs=basic%2Cportal&pivots=container-linux#limitations), this is not a supported case.

Knowing that Azure Files had backup options, large sizes available, etc., I decided to investigate the #2 option. It turns out, the Compose file does work with Azure Files mounted into the Compose, but there's a very specific way to do it. Specifically, utilize a named volume mounted at the same path. See [this Bicep](/assets/2025/azure-app-service/Compose.bicep) and [this compose yml](/assets/2025/azure-app-service/docker-compose.yml).

However, even with this "fixed" (which it isn't - it just appears fixed because it "works"), there was one last issue.

### Virtual Network Integration

As it says plainly in the docs, virtual network integration is not supported in the Compose scenario. This was a requirement to access a different Azure resource going through Azure-only networking pathways, so if a new architecture was going to be developed just to handle the virtual network requirement, should we even continue using Compose for App Service when Microsoft has clearly said that sidecars are the only supported method going forward?

## An Interim Thought

What if you could have used normal Compose deployment with a fully capable Docker daemon? Perhaps something like Docker in Docker? That would allow us to deploy an arbitrary large compose and have it behave like the normal deployment. Well, of course, it turns out, it's not possible to run Docker in Docker on Azure App Service since that requires privileged containers and privileged containers not allowed.

Sad day, but it is what it is.

## Second Iteration - All-in-One

This is where things are not being done in idiomatic ways. Perhaps the correct answer, after getting to this point, was to revisit the architectural limitation preventing us from using a different PaaS offering. But redoing architecture on your weekends is a recipe for burnout, so let's skip over that for a second.

So, if you know you need to run app services as single containers, you have two options:

1. Start deploying everything as separate App Services.
2. Do everything in a super sized single container.

The first is probably the most reasonable strategy, but this only works if your individual applications are all going to use HTTP/HTTPS between each other. But databases, message queues, or other applications may not utilize HTTP/HTTPS and thus, you are immediately back to the drawing board.

The second is very against the Docker paradigm. Remember, the desire is to run one process per container. To me, this is an entire topic on its own, but in my eyes, it's all about where you put your orchestration. An OS does orchestration via its init system or systemd. A container based system should be doing orchestration at the container level e.g. the Docker daemon or podman/similar. But, if your back is against the wall, and you need orchestration inside of the container, what is your option? Systemd does not work with a container for *reasons*. But... what if...

Enter [docker systemctl replacement](https://github.com/gdraheim/docker-systemctl-replacement). This software is a `systemctl` replacement and allows you to have a pseudo-systemd daemon running processes inside a container. The purpose behind this project appears to be around testing systemd services in a container environment, but at least from my standpoint, you can use this for running multiple services together in a single container with failure handling.

This is the dockerfile sample for preparing for this usage:

```dockerfile
RUN curl -kLR "https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/refs/heads/master/files/docker/systemctl3.py" -o /usr/bin/systemctl \
    && chmod +x /usr/bin/systemctl 
```

To utilize this, your startup command/entrypoint will end with something like:

```sh
exec systemctl init rabbitmq-server ssh traefik application
```

This works great. I do think there are probably improvements to this strategy to be more compliant with the 10 second Docker stop timeout (especially custom applications to have necessary stop timeouts), but for what it is, I'm thankful to the author as it's very helpful.

## Working Yet Not

So now, with an all-in-one Docker container, everything was now working with the virtual network integration and things could progress. Seems like a win, right?

Well, that was until the Azure Files issue reared its head. Obviously, we can't be fully certain about this next part due to things having been deployed in a customer's tenant and not being able to inspect configuration, but after some offline testing, we were able to confirm at least a portion of this.

The problem goes back to this statement.

>It isn't recommended to use storage mounts for local databases (such as SQLite) or for any other applications and components that rely on file handles and locks.

This is at the root of our final round of struggles. If persistence doesn't work in the same way as all of the storage engines expect (maybe because SMB shouldn't be used for this?), then you really don't have any choice but to not utilize the persistence options from Azure App Service. You **really** need to consider using some sort of managed persistence option e.g. a managed database offering or go back to using virtual machines with the disks that behave like real disks.

In our experience, the database engine would seemingly work for hours or even days, and then suddenly, it would not be able to do anything with its own storage. By anything, I mean, modify files or delete files in its storage area would both silently fail. Switching away from hosting the storage engine in the App Service to out of the app service via a managed offering, everything started working much more like you'd expect.

## Conclusion

My lesson learned is to really understand the templates and tutorials for PaaS offerings. If they neglect to talk about persistence or always show the PaaS offering being used in conjunction with a managed database offering, you best be thinking about *why* that is the case. Obviously, for many folks, you would jump to the conclusion that it's upselling or promoting other first party offerings; but in this case, it's because App Service does not have any persistence options that allow applications that rely on file handles/locks to function as correctly as they would on a VM.

Personally, I feel that persistence in k8s is similar to this. Persistent volumes with multiple instances across multiple nodes seems like a Hard Problem™ and almost always requires an [external solution to the compute node](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#types-of-persistent-volumes).

Simple solution: use the managed offerings for persisting data that are available to you.

## Misc Reference Links

- [Discussion on /home storage internals](https://learn.microsoft.com/en-us/azure/app-service/operating-system-functionality#types-of-file-access-granted-to-an-app)
- [Databases via Azure Files is not supported](https://learn.microsoft.com/en-us/azure/app-service/configure-connect-to-azure-storage?tabs=basic%2Cportal&pivots=container-linux#troubleshooting)
- [Similar in theory situation where the managed offering doesn't support what you want so the end result is to abandon that in favor of the more complete one](https://xaviergeerinck.com/2022/10/18/deploying-timescaledb-on-azure-to-store-your-iot-data/)

[Here](https://github.com/sbhenderson/sbhenderson.github.io/tree/main/assets/2025/azure-app-service) is the link for the containing folder.