---
layout: post
title:  "Vibe Coding In Practice"
tags: ai development
---
Without rehashing what everyone knows, vibe coding is an interesting "feeling" in the industry. It neglects certain complexities with software and its development while seemingly having sufficient competence to get real work done.

I decided to embark on a vibe coding exercise as a way to determine for myself what is the current state and whether we should be scared or if it's overhyped. The results will be stored in the commit history of [this repo](https://github.com/sbhenderson/nellis-scanner). I will be putting each prompt I send with some observations in [this file](/assets/2025/vibe-code/PromptsUsed.md) ([GitHub visualization](https://github.com/sbhenderson/sbhenderson.github.io/blob/main/assets/2025/vibe-code/PromptsUsed.md)).

One huge thing is that I absolutely do not believe under any circumstance that you should be acting as a "hypeman" to an AI assistant. For example, this [rule](https://cursor.directory/front-end-cursor-rules):
>You are a Senior Front-End Developer and an Expert in ReactJS, NextJS, JavaScript, TypeScript, HTML, CSS and modern UI/UX frameworks (e.g., TailwindCSS, Shadcn, Radix). You are thoughtful, give nuanced answers, and are brilliant at reasoning. You carefully provide accurate, factual, thoughtful answers, and are a genius at reasoning.

I am sorry, but that's frankly unacceptable. LLMs are unfeeling machines. They may emulate human responses but that is because they were trained to do so (whole subject on this, but I thought this [article/discussion](https://slashdot.org/story/25/05/05/0234215/after-reddit-thread-on-chatgpt-induced-psychosis-openai-rolls-back-gpt4o-update) is easy to see the dangers). With that said, if we were this kind and generous to humans who were fulfilling roles/jobs in our society, I wonder if it would be a net benefit to society.

## The Actual Vibe Coding & Summary

So I did "complete" (as much as software is ever "complete") what I set out to do: get a first hand feel for vibe coding and have some takeaways. You can see the resulting repository [here](https://github.com/sbhenderson/nellis-scanner). I used VS Code and GitHub Copilot exclusively with Claude 3.7 Sonnet to perform the prompts mentioned above. The solution was done in C#/Blazor where I have some reasonable knowledge and can see certain obvious problems.

Overall, my feeling is effectively *impressed with caveats*. Without a doubt, I got a lot of lines of code out of the use of it. Prior to this exercise, my feeling was that AI would be best served in small function-level changes where context is sufficient and no actions have to take place beyond attempting to write a function. However, after this, I see that agent-based workflows are **real**. Asking the LLM to create a new project with some fairly high level details and have it create it is frankly awesome. I got to sit back and just watch it work. One of the single most impressive moments for me was when it needed to run `dotnet new` but the options for the template changed for .NET 9, and instead of crashing or even going to the internet, it just queried the `--help` on the specific template to see the new switch needed.

Going further, once I set the proper options in VS Code to "YOLO" mode (`chat.tools.autoApprove` and to a lesser degree `chat.editing.confirmEditRequestRetry` and `chat.agent.maxRequests`), it really was truly set and forget.

Before getting into the problems encountered, I'd wager that the *AI agent* I used for the language/runtime was somewhere between a university grad and a mid-level developer. Now, I will fully admit that I did not hype up the AI nor did I provide it super in-depth instructions. I give this relative range of experience because the code was adequate in a lot of ways (if not, most), but it had sufficient problems and failings that would make me question whether a person was actually thinking about the problem or general expectations. I might, for example, believe that if I ask you to use Tailwind instead of Bootstrap, I'd hope you'd use the latest version of Tailwind so we can avoid rehashing the issue later. With all that said, for delivering features and fixes that can at least be described in some high level way against the backdrop of context lengths and its relationship to size of codebases, **AI agents seem like they are valuable.**

## The Problems

Software development is, without a doubt, a subjective endeavor. I place it alongside classic engineering disciplines in that while there are objective optimums when isolated, when you consider the human evaluation/metrics, subjectivity plays a major part. So, I am taking a subjective view of this AI just like someone else can take a subjective view of my work; it is simply my opinion of its output.

In general, my biggest complaint is that the AI really **really** struggles with more esoteric and newer technologies. Perhaps this is expected, but when it does not have a good understanding of the language and runtime, it does, frankly, bad things.

Example from the codebase. In `Inventory.razor`, I needed to basically refresh the grid of inventory listings when the SortBy changes. Mind you, this was a bug the AI left in for me. So, after looking at it for a moment, I realized that the answer required a little more investigation from myself. Before going to Kagi, I asked Copilot:

**Q:**
> In Blazor, what is the best mechanism to have a function be executed when a @bind property changes?

**A:**
>Handling @bind Property Changes in Blazor
>
>In Blazor, when you need to execute a function when a bound property changes, you have a few options:
>
>1. Use `@bind:event` and add an event handler
>
>You can pair the standard `@bind` with a specific event trigger using `@bind:event` and then add an additional event handler:
>
>```razor
><select @bind="SortBy" @bind:event="onchange" @onchange="OnSortByChanged" class="...">
>    <!-- options -->
></select>
>```
>
>```csharp
>private async Task OnSortByChanged(ChangeEventArgs e)
>{
>    // SortBy value is already updated via the binding
>    await ApplyFilters();
>}
>```
>
>2. Use property setter
>
>You can implement a property setter to execute code when the value changes:
>
>```csharp
>private string _sortBy = "last_seen_desc";
>private string SortBy
>{
>    get => _sortBy;
>    set
>    {
>        if (_sortBy != value)
>        {
>            _sortBy = value;
>            ApplyFiltersAsync().ConfigureAwait(false);
>        }
>    }
>}
>```
>
>3. Create a separate event handler
>
>Instead of using `@bind`, you can directly handle the change event:
>
>```razor
><select value="@SortBy" @onchange="SortByChanged" class="...">
>    <!-- options -->
></select>
>```
>
>```csharp
>private async Task SortByChanged(ChangeEventArgs e)
>{
>    SortBy = e.Value?.ToString() ?? "last_seen_desc";
>    await ApplyFilters();
>}
>```
>
>For your `auctions_desc` case in the Inventory component, I'd recommend option 1 or 3 since they provide the cleanest separation between the value binding and the event handling logic.

**Q:**
> Why didn't you just suggest @bind-after?

**A:**
>Using `@bind:after` in Blazor
>
>You're absolutely right to point out `@bind:after` - it's actually already being used in your code, and I should have highlighted it as the preferred solution:
>
>```razor
><select @bind="SortBy" @bind:after="ApplyFilters" class="w-full rounded border-gray-300 shadow-xs px-4 py-2 focus:ring-blue-500 focus:border-blue-500">
>```
>
>The `@bind:after` directive is indeed the cleanest approach for this scenario. It allows you to:
>
>1. Bind the value normally with `@bind="SortBy"`
>2. Automatically execute a method after the binding completes with `@bind:after="ApplyFilters"`
>
>This is more concise than the other options I suggested and keeps the binding and subsequent action clearly connected without needing additional event handlers or property setters.
>
>Thanks for pointing this out - it's the most elegant solution for executing code after a bound property changes in Blazor.

How??? Why?? For something so basic that's been around for ~2 years, the fact that it wasn't even an option just shows how painful this can be.

### Random Unfiltered Problems

* In Prompt 02, we asked it to replace the default Bootstrap reference with Tailwind. For reasons, I did not yet have Node installed. So when it tried to install Tailwind via `npm`, it failed to do so. The consequence that wasn't obvious was that it used the CDN Tailwind JS approach and used the v3 version. Perhaps, if it had installed via `npm`, it would have been on v4. Even so, I'm not sure that would have helped later.
* In Prompt 12, I tried to get it to upgrade to Tailwind v4, and all I can say is that it simply could not handle this properly. Perhaps copy/pasting the table from Tailwind's website was not detailed enough, but it simply did not handle any of the complexity of this topic. Again, you can probably criticize the prompt, but honestly, I'd ask a junior engineer "Upgrade it to Tailwind v4, let me know when it's done". Hand-holding only reinforces the notion that it is intrinsically inferior.
* The Blazor charting runaround was suboptimal. It used an outdated library at first, and then when it tried switching to something newer, it did not properly install it i.e. add it to the `Program.cs`.
* Failed to set the Blazor render mode, and as a result, the application was totally devoid of interaction as the new default is static SSR.
* It opted for `character varying` by specifying max lengths in the DbContext, but since it knew it was using PostgreSQL, PostgreSQL has made it clear that there is very little, if any, [performance to be gained from this](https://www.postgresql.org/docs/current/datatype-character.html). But max length only introduces the possibility of unintended breakage. This is one of those subtle, but weird issues.
* Asking for a `RunOnce` mode in 07 generated a crazy outcome - it wanted to do extra parsing at the beginning and generate an entire if/else tree in the `Program.cs` from the beginning of the file duplicating almost everything. Really, the solution is trivial - just opt to do your run once logic instead of running the app like normal.
* I asked it to generate a GitHub action in 06, and to its credit, it did do it. By a quick review, it would have worked. But it neglected GitHub's latest template which had more to do with signing of the container images. I opted for the GitHub one, but this is another case of being disconnected from the latest docs/templates causes needless friction.
* I felt like I had to ask for it to build, cleanup errors, and test itself more than not. Again, maybe you have to prompt it to "Please Billy, build the code before you tell me you're done and that this new upgrade will be a major improvement to the software." Yes, junior engineers often go through this whole thing as well, but I definitely only have to ask once or twice.

### Random General Thoughts

* I will say, the overall process felt slow. It took quite a while (like >20 minutes) for the agent to complete some of these requests. Again, time efficiency wise, I'm not sure I can argue against it, but that was surprising to some extent.
* As a developer, it's hard to want to sit there and type out how I want certain problems to be solved. This is why you hire capable humans - you can provide a small amount of instruction and get a disproportionate amount of correct work out the other side. Here, I feel like that ratio is wrong. If you are good at the technical parts of software, there are probably problems that would take less time for you to solve in the way you are intending them to be solved using your development workflow vs. writing an essay.
* I also felt that writing some of this stuff up in sufficient detail almost took the joy out of it. Instead of actually doing technical work, I am simply writing instructions for "someone else" and that "someone else" will not remember your preferences as it relates to their output. Perhaps others have felt this about historical developments e.g. the evolution of programming, but in all those cases, I feel it was a subjective assessment of "productivity" and how tooling does or does not help a given person versus the "will it replace me?" vibe.

## Conclusion

Without a doubt, I have come to appreciate the power of these new tools. While they definitely have some problems, there is a lot to be gained if your problem fits neatly into the context window and you're not depending on technology that is too niche for it to not be trained on enough. If these models start bringing in the latest information from StackOverflow, Reddit, Hacker News, docs, etc. while being able to hold the entire codebase in context, without a doubt, I think you'll start to see some amazing stuff. I know that the Llama 4 models have incredibly long context windows, so perhaps that day is sooner than we were expecting.

In my humble opinion though, I think all of these LLMs will have a peak soon enough with their capabilities due to the ouroboros of consuming AI generated content for training (as it's totally unavoidable at this point) as well as no logical/rational basis at the core of the LLMs. I also wonder if developers actually *want* to use some of this tooling. What was once writing code in an editor, thinking about memory, logic, threads, etc. can now just be technically relevant markdown-formatted text. Is this what developers thought the future would be?

I do think that AI does not appear poised to replace technically competent and curious people especially those with niche knowledge and understanding. However, it does seem like anyone who is acting as a small scope black box (i.e. small context/scope, limited and defined inputs, limited and defined outputs), AI may be competitive. World sure changes fast, at times.
