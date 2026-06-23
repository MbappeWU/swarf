# I shipped a Mac cleaner, launched it on 8 channels, and made $0. Here's the autopsy.

> A build-in-public postmortem. Adapt for dev.to / a personal blog / 少数派 / V2EX.
> Failure stories travel *because* they're honest — don't sand off the embarrassing parts.

I spent weeks building MacSweep: a native macOS disk cleaner. Apple-notarized, universal
binary, React GUI in a Swift shell, a Bash engine, a working license server, a real
freemium paywall. It was, by any engineering measure, done.

It made **zero dollars**. One download — me. Here's everything that went wrong, with the
receipts, because I had to stop lying to myself about which part was actually broken.

## Myth #1: "I never really launched it"

That's the comfortable story. It's false. I checked my own launch tracker line by line:

- Product Hunt — **live**. 0 upvotes.
- Twitter thread — **posted**. 0 impressions.
- r/SideProject — **posted**. 0 upvotes.
- AlternativeTo, an SEO blog post, GitHub topics, a Homebrew tap — **all shipped**.

I launched on eight surfaces. Every single one returned exactly zero. "Just post it" was
never the problem. **I posted, and the world didn't notice.** That's a much worse diagnosis,
and the right one.

## The three real reasons it was always going to be zero

**1. I had no audience, so "launching" reached no one.** Product Hunt ranks on upvote
velocity in the first hours — I had no network to seed it, so it sank. A 0-follower Twitter
account gets shown to ~nobody. A low-karma Reddit post sinks on submit. I'd built a product
with no distribution capacity, and distribution capacity isn't something you bolt on at
launch — it's the thing you build *first*.

**2. The brand was un-findable by construction.** My domain collided with a popular VR game,
so the site was invisible in search. Worse, the product name itself collided with a piece of
2008 scareware that search engines *warn people about*. A cleaner whose entire pitch is
"trust me, I'm the safe one" — and its name triggered scam warnings. I did that to myself.

**3. I picked the most saturated, most skeptical market possible.** "Mac cleaner" is a
category people associate with scams, locked up by entrenched paid apps and free
alternatives. And I pitched it to Reddit/HN/V2EX power users — the exact crowd whose reflex
is "Mac cleaners are pointless, just use `rm -rf`." I was selling ice to people who live in
Antarctica and distrust ice salesmen.

Oh, and during the actual launch week, my checkout page was returning a 404. So even the
zero visitors who showed up couldn't have paid.

## The lesson, in one line

**Distribution and trust are the product. The app is the easy part.**

I had it exactly backwards. I treated "ship the app" as the finish line and "tell people" as
a checklist to run afterward. For anything you want strangers to pay for, it's the reverse:
the audience and the discoverability *are* the work, and the code is the part that's
table-stakes.

## So what now?

I'm not reviving MacSweep — that fight is lost and not worth the hours. But the one piece of
it I actually liked was the developer-junk scanner, and that has a real, narrow audience that
respects a focused open-source tool. So I pulled it out, gave it a name that doesn't trigger
malware warnings, made it free and open-source, and I'm shipping it the way I should have
the first time — to a specific audience, on its merits, with the discoverability built in.

It's called [swarf](https://github.com/MbappeWU/swarf). It's one Bash file that reclaims a
Mac dev's disk space — node_modules and the Xcode junk — and moves it to the Trash instead of
deleting it. It found 3.6 GB on my own machine while I was writing this.

That's the whole turnaround: stop building in a cave and "launching" cold. Pick a real
audience. Earn discovery instead of buying a checklist. We'll see if it works — but at least
this time I know what the actual game is.

*If you've shipped something to silence, you're not bad at building. You're missing the half
of the job nobody put on the roadmap. That half is the job.*
