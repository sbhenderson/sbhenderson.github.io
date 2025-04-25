---
layout: post
title:  "Home Power Optimization Part 1"
tags: home energy development
---
## Background

In 2024, I purchased (or started the process as it was installed a few weeks ago) 4x [Enphase IQ-5P](https://enphase.com/store/storage/gen3/iq-battery-5p) which, when combined with my previous 32 400W panels, meant I was finally whole home backup for when the Houston area has more power outages. But, while the goal was to eliminate the need to concern myself with power outages, something more practical day to day is having an electricity plan that optimizes for the use of these batteries. Texas is somewhat unique in that in some jurisdictions, you are able to choose what type of plan you want. Some sample options:

* Flat rate all day every day for the contract length
* Time of use plans with no free periods
* Flat rate for import, a separate rate for export (could be flat/constant or be connected to RTW - real time wholesale)
* Free electricity on weekends
* Free electricity during nights (generally between 21:00-07:00, but it varies)
* Free electricity during the day
* VPP (Virtual Power Plant) where you are obligated to produce electricity on demand or reduce electricity consumption during certain periods (or its inverse - demand a certain percent of electricity import)

While the last seems like the correct option, in my opinion, the problem is that **free** periods are actually **free**. Normally, importing electricity, even at a small rate like $0.01/kWh demands that you pay the transmission fee. For the greater Houston area, it's currently about 4.8¢/kWh. But the way these free period plans work is that the provider waives the transmission fee; obviously, in exchange for this deal, they levy a substantially higher rate during other periods.

Anyway, comparing plans is quite difficult, and using historical consumption patterns only tells half the story; if you were going to use X amount of electricity in a day but could time optimize a portion of usage, a free period plan could in fact save you a ton of money. Another difficult aspect is that, if you have surplus energy/power to sell to the grid, how do plans that offer that affect your usage behavior? For example, selling at wholesale rates in Texas at certain times of the year at certain times of the day could be **very** lucrative (as electricity can go upwards of $4-$9/kWh).

Truly, a proper calculator considering potential behavior changes requires a fair amount of planning. Holler at me if you know of a tool that is actually reasonable or you'd like to build one.

## Problem Statement

Knowing I'm going to switch to a free nights plan, I want to minimize electricity costs during the day. But, seeing as I have a family of folks trying to live their lives, I want to do this using automation. Effectively, I have a few knobs I want to turn during the day:

* HVAC - Ecobee - If I'm in a good position, let's cool the house more. Otherwise, let's turn it off/move the setpoint.
* Electric car charger - Wallbox Pulsar 40A - I can lower the usage of the charger or even pause it together

In the future, I may want more knobs. Thinking about an electric dryer, you probably don't want to drain down your battery to dry your clothes. But what's the right way to manipulate this? I am sure someone has thought of this whether it's a load shedding breaker, a home automation friendly plug, or something else entirely.

With this, I basically want a control strategy to handle the following major orthogonal issues:

1. Is the grid available or not?
2. Is the current time during the free use period or not?
3. What is the current charge level of the battery?
4. Do we have sufficient surplus power?

Now, if you directly attack that orthogonality, you end up with N*N states to deal with. Worse, control philosophy should be partially based on the future. For example, what is my forecasted production? However, forecast of hyperlocal phenomena i.e. amount of sunshine my panels will receive, is difficult? Impossible? So ignoring future state or amount of time until changing of periods (thinking about drawdown type calculations), I think for simplification, we can break it down to this hierarchy of cases:

1. When the grid goes down, set state to Conserve. If it's the middle of the day and we have surplus power, we can use human intervention to control this as there are too many potential factors to consider here. Vice versa, when the grid comes back up, do nothing and allow the rest of the automation to handle this.
2. When the grid is up:
    1. If we are in the free use period, set state to High.
    2. If we are not in free use period and we are below reserve limit, set state to Conserve.
    3. If we are not in free use period and are above minimum reserve limit:
        1. If solar production is < 1 kW, set state to Conserve.
        2. If solar production is > 1 kW, set state to Normal.
        3. If solar production is > 4 kW, set state to High.

State meanings:

* Conserve = turn off HVAC (or set setpoint sufficiently away from current) and pause EV charger
* Normal = keep HVAC at "normal" levels and allow EV charger to charge at 8A
* High = utilize HVAC at overcool levels and allow EV charger to charge at 40A

Why 1 kW? Well, my house with my home lab and normal lighting/TV is about 600-800 W. I have questioned how it's possible that my usage is at least 600W at all hours, but that's an investigation for another day.

Obviously, there are so many potential options and options on those options especially if you incorporate future state. Perhaps this is why certain jurisdictions prefer to not make people think about this problem and control devices remotely via grid actions. But I think the above is reasonable enough.

## Initial Thought on Implementation

So, as an engineer/developer does, the first thing many of us may think of doing is start architecting. Well, I'll need to fetch data from these different services. How, are there specifications, are there libraries, etc. etc. etc.?

First big sticking point in my research: Ecobee doesn't allow arbitrary integrations anymore. If you didn't sign up, you can't use their API:

> Sorry, we are not currently accepting new developer registrations at this time.

Well, that's a huge bummer and that's like half the problem. My version of the Ecobee was integrated into Homekit, but crafting a system that was going to read/write state to an ecosystem that didn't seem the most friendly to develop against did not seem to be on my top ten list of things to do.

## A Better Path: Home Assistant

Of course, it pays to investigate alternatives rather than jumping straight in. In this case, the savior is [Home Assistant](https://www.home-assistant.io/). Following major features:

1. Can self host
2. Has integrations to Enphase Envoy, Ecobee via the API or directly via Homekit, Wallbox, and *so many more*
3. Has a reasonable API itself!

Slam dunk right there. Now, it's not to say everything is perfect. I understand why they chose [Jinja markup](https://palletsprojects.com/projects/jinja) since Home Assistant is Python, but it is somewhat obtuse for me. I also feel that certain core aspects of the software are kept in this pseudo-modular approach. A key one to me is the `history` integration which is fundamental to so many things yet is difficult to configure. This balance between what is the config file vs. what is stored in the DB is also a strange one to me. But look, it's always easier to criticize than to build a free piece of software used by thousands, so long story short, this is a great piece of software and perfect for my needs.

Here's an example of a template for "rectifying" a signal:

{% raw %}

```jinja2
{% set netpower = states('sensor.envoy_122042083566_current_net_power_consumption')|float(0) %}
{% if netpower >= 0 %}
{{ netpower }}
{% else %}
0
{% endif %}
```

{% endraw %}

Here's a dashboard I built:

![Basic Dashboard](/assets/2025/home-power/Dashboard.png)

## Next Steps

Now that I have this in my homelab, I just need to setup the automation. That will be in the next post when I switch to the free nights plan. I'll add a link here when done.

## References

* [Solid guide to understanding plans that have solar buyback](https://www.texaspowerguide.com/solar-buyback-plans-texas/)
* [Good guide to finding plans with free electricity periods](https://electricityplans.com/)
