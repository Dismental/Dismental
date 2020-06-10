**deps_before_adding_suffx**

This is the most recent `.zip` of our dependencies.
This `.zip` was made before adding a suffix to every lib, it contains the third party dependencies found in `/usr/local/opt/` and `/usr/local/Cellar`.
It also contains the libraries we use from `/usr/lib/`.
For every library the `LC_LOAD_DYLIB` has been adjusted.
All of the libraries in this file request libraries from one of the following locations:
* `@loader_path/` 
* `@rpath/`
* `/System/Library/Frameworks/`

**dependencies.zip && dependencies_2.zip**

Contains the third party dependencies found in `/usr/local/opt/` and `/usr/local/Cellar`.
For every library the `LC_LOAD_DYLIB` has been adjusted.
All of the libraries in this file request libraries from one of the following locations:
* `@loader_path/` 
* `@rpath/`
* `/System/Library/Frameworks/`
* `/usr/lib/`