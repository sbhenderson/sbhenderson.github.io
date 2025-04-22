---
layout: post
title:  "Onyx Storm Target Redsky Checker"
categories: python
---

The background here was that my wife really wanted the [*Onyx Storm* by Rebecca Yarros Target exclusive super duper collector's edition](https://www.target.com/p/onyx-storm-target-exclusive-edition-by-rebecca-yarros-hardcover/-/A-93038252), but because she didn't think it'd be so popular or as cool as it was, didn't preorder or purchase it as soon as it came out. Taget's website is actually really good for knowing when things are in stock, but at the store, inventory management is probably next to impossible to correctly deal with. We went to multiple Target stores in the area that had the book "in stock" but found upon arrival that it was nowhere to be found. Maybe someone had it in their cart, maybe it was behind the register, returns, etc.

So, in an effort to help with this and provide more us with more stores to go to next, I wrote a [super simple Python script](/assets/2025/target-checker/TargetBookChecker.py). So simple that it didn't work at first (because I didn't bother testing adding something to an array via `push` instead of the correct `append` - and of course, VS Code did not warn me).

First cool thing was regarding Target's RedSky API. Target seems to do a good job of making this open and available without needing to do anything crazy with tokens to query it. Some links:

- [GitHub gist from LumaDevelopment discussing it more in depth](https://gist.github.com/LumaDevelopment/f2a34a202fed6ab5a7f3a31282834943)
- [Article from Tom Rauk at Target](https://tech.target.com/blog/empowering-clients-api)

Second part that I thought was cool was how to notify me that it's in stock. In the modern world, you have so many options, but the ones that are simplest in my eyes are:

1. View the output of the script and see if it ended. Manual but effective.
2. Send an email.
3. Send an SMS.
4. Send a notification to my phone.

I wanted something more automatic, but I didn't want to go digging around in how to get a token to send via SMTP on any of my email addresses (due to the usage of MFA everywhere). This is not impossible to overcome and is straight forward, but I just wanted to mix it up a little. So I was like, surely SMS or notification shouldn't be too hard, right?

Well, SMS is not fun these days. Twilio, which seems to be the standard folks use, made it really difficult, in my opinion, to send text messages to my own phone. It seems like you have to sign up for a toll free number to send from (that was easy) but then to continue sending, you had to become verified. [Twilio help article](https://help.twilio.com/articles/5377174717595-Toll-Free-Message-Verification-for-US-Canada) and this [extra piece of info](https://www.twilio.com/docs/messaging/compliance/toll-free/console-onboarding). All the tutorials were written before 2025-01-31, so maybe they'll add change to add the piece of sending in identity data to Twilio so you can send free text messages to yourself for a few days. That's going to be a hard pass from me.

So, then I thought, hey, surely someone somewhere has done something to send arbitrary notifications to your own phone, right? Luckily, it does seem like this is reasonably common. I chose [Pushover](https://pushover.net/) because it works and is cheap ($5 for effectively unlimited notifications to any iOS device you are willing to register and install the app on)? Technically speaking, I did not need to pay for it since it includes a 30 day trial, but after seeing how it worked, I decided to just buy the permanent license. See example code:

```python
pushover = Pushover(user_key=user_key, api_token=app_key)
pushover.send_message(message= message, title='Onyx Storm Available')

```

Anyway, at the end of it, we were able to pick up two books (one for the wife, one for the sister-in-law). From the Target employee who put it back on the shelf, it seems like someone had returned four of these. Speculation was that they didn't sell quickly enough on second-hand markets. Scaplers...

![Two Onyx Storm books](/assets/2025/target-checker/success.jpeg)

### Reference

[Here](https://github.com/sbhenderson/sbhenderson.github.io/tree/main/assets/2025/target-checker) is the folder containing the "solution".
