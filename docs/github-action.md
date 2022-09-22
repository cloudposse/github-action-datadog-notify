<!-- markdownlint-disable -->
## Inputs

| Name | Description | Default | Required |
|------|-------------|---------|----------|
| alert\_type | Type of the event, one of: error,warning,info,success,user\_update,recommendation,snapshot | info | true |
| api\_key | Datadog API Key | N/A | true |
| append\_hostname\_tag | Should we append the hostname as a tag to the event, set this to the key of the tag |  | false |
| tags | Space separated list of Tags for the event | N/A | true |
| text | Description of the event | N/A | true |
| title | Title of the event | N/A | true |

## Outputs

| Name | Description |
|------|-------------|
<!-- markdownlint-restore -->
