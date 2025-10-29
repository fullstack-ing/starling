# Starling

A more frontend agnostic Elixir Phoenix (Currently WIP)

## Motivation: (Just my opinions)

* Phoenix generators push too many opinions. (phx.gen.html / phx.gen.live)
* Daisy UI does not do enough to justify being added in addition to tailwind.
* Tailwind is overkill and makes your dom a mess with annotations.
* Tailwind is over compensation for not wanting to use basic css standards.
* Liveview's trade offs create more complexity than they provide meaningful features most of the time.
* Liveview is over compensation for not wanting to use web components.
* Everything above is basicly a 3rd party to your system, which means more to maintain overtime.
* FOMO: I felt I was ignoring inovation and evoling standards happing in css and browser support because I let a 3rd party get in the way.
* I wanted to improve skills that are rooted in standards, agnostic and generic vs spending more time learning yet another ever changing niche 3rd party.
* I was getting fustred with having to opt out of niche features and still finding remanants of them in the code base anytime I used a generator.
* AI is starting to remove the need for these complex 3rd party solutions to "being more productive".
* I wanted ingredients not a fully baked cake.

## What is diffrent about this project?

At the moment this project is nothing more than an example of what such a end result would look like if you:

* Removed Liveview and replaced it with Web Components.
* Removed DaiyUI & Tailwind and replaced them with Standard CSS.
* Migrated Esbuild back to npm.
* Used lightning CSS for your styles.

## Goals:

* Build generators that respect my choice (IE core_components.ex and html dom littered with daisyUI/tailwind)
* Build generators that create a sensable css starting points that supports better standards vs obscuring them.
* Build generators that embrace web components vs trying to replace them with their own noval approch.

I'm doing this sololy from a selfish standpoint and these opinions are my own.
I'm doing this to tell you that you are wrong for wanting Tailwind / Liveview.
Instead I'm saying that I gave it an honest try and really wanted to love it, but sadly it never fully clicked for me.
