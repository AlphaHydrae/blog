---
layout: post
title: You should refactor all the time
date: '2021-01-22 20:00:00 +0100'
comments: true
today:
  type: think
categories: programming
tags: refactoring
---

Have you seen code rot? I have. A lot of it was my own code.

The more I learn about programming, the more I realize that [refactoring] must
be an ongoing activity that you perform every day if you want to maintain the
quality of your code and your architecture. It should never be a task that you
schedule at the end of an iteration or a project–something that will be dropped
at the first sign of an impending deadline.

I'm not the first to think this. I seem to be in good company.

<!-- more -->

## The Equation of Software Design

By Max Kanat-Alexander in [*Code Simplicity*][code-simplicity]:

[{% img right {{ site.baseurl }}/assets/books/code-simplicity.jpg 150 %}][code-simplicity]

> The desirability of a change is directly proportional to the value now plus
> the future value, and inversely proportional to the effort of implementation
> plus the effort of maintenance.

When you're in it for the long haul, the effort of implementation will
eventually be insignificant compared to the cumulated effort of maintenance.
Therefore:

> It is more important to reduce the effort of maintenance than it is to reduce
> the effort of implementation.
>
> The quality level of your design should be proportional to the length of
> future time in which your system will continue to help people.

You can't afford to skip refactoring and let a significant amount of cruft
accumulate. It *will* come back to haunt you.

## The Cycles of TDD

By Robert C. Martin, a.k.a. *Uncle Bob*, in [*The Cycles of
TDD*][the-cycles-of-tdd]:

> ### Micro cycle: Red-Green-Refactor
>
> The micro-cycle that experienced TDDers follow. The Red/Green/Refactor
> cycle. [...]
>
> * Create a unit tests that fails
> * Write production code that makes that test pass.
> * Clean up the mess you just made.
>
> The philosophy is based on the idea that our limited minds are not capable of
> pursuing the two simultaneous goals of all software systems: **1. Correct
> behavior**. **2. Correct structure**. So the RGR cycle tells us to first focus
> on making the software work correctly; and then, and only then, to focus on
> giving that working software a long-term survivable structure.
>
> Again, many people have written about this cycle. Indeed the idea derives from
> Kent Beck’s original injunction:
>
> > *Make it work. Make it right. Make it fast.*
>
> Another way to think about this idea is:
>
> > *Getting software to work is only half of the job.*
>
> Customers value two things about software. The way it makes a machine behave;
> and the ease with which it can be changed. Compromise either of those two
> values and the software will diminish in real value to the customer.
>
> Executing the Red/Green/Refactor cycle takes on the order of a minute or so.
> This is the granularity of refactoring. Refactoring is not something you do at
> the end of the project; it’s something you do on a minute-by-minute basis.
> There is no task on the project plan that says: Refactor. There is no time
> reserved at the end of the project, or the iteration, or the day, for
> refactoring. Refactoring is a continuous in-process activity, not something
> that is done late (and therefore optionally).

## A Design for Developers

By Eric Evans in [*Domain-Driven Design: Tackling Complexity in the Heart of
Software*][domain-driven-design]:

> [{% img right {{ site.baseurl }}/assets/books/domain-driven-design.jpg 150 %}][domain-driven-design]
>
> Software isn’t just for users. It’s also for developers. Developers have to
> integrate code with other parts of the system. In an iterative process,
> developers change the code again and again. Refactoring towards deeper insight
> both leads to and benefits from a supple design. […]
>
> If you wait until you can make a complete justification for a change, you’ve
> waited too long. Your project is already incurring heavy costs, and the
> postponed changes will be harder to make because the target code will have
> been more elaborated and more embedded in other code.
>
> Continuous refactoring has come to be considered a “best practice”, but most
> project teams are still too cautious about it. They see the risk of changing
> code and the cost of developer time to make a change; but what’s harder to see
> is the risk of keeping an awkward design and the cost of working around that
> design. Developers who want to refactor are often asked to justify the
> decision. Although this seems reasonable, it makes an already difficult thing
> impossibly difficult, and tends to squelch refactoring (or drive it
> underground). Software development is not such a predictable process that the
> benefits of a change or the costs of not making a change can be accurately
> calculated.
>
> […] Therefore, refactor when:
>
> * The design does not express the team’s current understanding of the domain;
> * Important concepts are implicit in the design (and you see a way to make
>   them explicit); or
> * You see an opportunity to make some important part of the design suppler.
>
> This aggressive attitude does not justify any change at any time. Don’t
> refactor the day before a release. Don’t introduce “supple designs” that are
> just demonstrations of technical virtuosity but fail to cut to the core of the
> domain. Don’t introduce a “deeper model” that you couldn’t convince a domain
> expert to use, no matter how elegant it seems. Don’t be absolute about things,
> but push beyond the comfort zone in the direction of favoring refactoring.

[code-simplicity]: https://www.oreilly.com/library/view/code-simplicity/9781449314750/
[domain-driven-design]: https://www.oreilly.com/library/view/domain-driven-design-tackling/0321125215/
[refactoring]: https://en.wikipedia.org/wiki/Code_refactoring
[the-cycles-of-tdd]: https://blog.cleancoder.com/uncle-bob/2014/12/17/TheCyclesOfTDD.html
