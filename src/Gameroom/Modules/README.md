These modules are define the more complex top-level routes only. They look like components, but they're not intended for re-use, and the 'nesting' stops at one level. The way they work is that the models of these modules are included in the route definition:

`type alias Route = RouteOne ModuleOneModel | RouteTwo ModuleTwoModel | ...`

One added benefit here is that route-specific state info gets wiped out automatically when the route changes.

As per [this](https://guide.elm-lang.org/reuse/) and [this](https://www.elm-tutorial.org/en/02-elm-arch/06-composing.html), as well as many community discussions online, such nesting should be kept to a minimum to avoid boilerplate and awkward-looking code, and I wonder sometimes why I'm doing this in the first place. Probably just a preference to keep such closely related code close, or to be able to mentally ignore the rest of the code while working on these little guys.
