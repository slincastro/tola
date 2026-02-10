

# Infrastructure Deploy

```mermaid
flowchart TD
    A[Infrastructure] -->|Deploy in AWS| B(Deploy)
    B --> C{Everything Ok ?}
    C -->|OK| D[Deploy new Infra]
    C -->|Fail| E[Cry]