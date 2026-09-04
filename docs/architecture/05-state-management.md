# State Management

## Principles

- Prefer one authoritative source for each piece of state.
- Avoid duplicated state between modules.
- Prefer event-driven updates.
- Cache only when it provides measurable benefit.
- Keep transient UI state local to the component.

## Example

The compositor service owns active workspace state.

The bar observes it.

The overview observes it.

Neither should maintain an independent authoritative copy.
