### What is this?

My personal setup for provisioning and configuring a remote development machine.

### Why?

All my day to day development is already done through tmux+vim and my old mac is 
slowly dying, so I want to try and see if it's possible to use a VPS as
my main development environment.

...so instead of just manually spinning up a droplet on Digital Ocean, I'm
starting out by learning Terraform. I might even figure out how to use ansible,
puppet, chef or salt and add this to the mix as well. Stay tuned!


### Is this ready?

Not at all. This is very much a WIP, but feel free to add PRs or issues.


### Mad science goal

Be able to spin up a new development environment on demand and destroy it when
it's not used. In some far future, it could be possible to spin up a fresh
development environment in the morning before starting work and destroy it when
I'm done. With hourly billing on most cloud computing platforms, this would end
up being a cheap way to have a workstation on demand.

...This will require some extremely polished dotfiles and that the projects that
I work one have been correctly dockerized for dev work.
