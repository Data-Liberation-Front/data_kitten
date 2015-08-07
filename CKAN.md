# Notes on CKAN API

## General

There are 3 versions of the API (1,2 and 3), documented [here](http://docs.ckan.org/en/latest/api/index.html). Things we mostly use (at moment of writing):

- `/api/3/action/package_show?id={package_id}` Lists all metadata for a package/dataset. We only use this _sometimes_ to get the `id` of the dataset, and then request all data via the old `/api/2/rest/package`. 
- `/api/3/action/organization_show?id={organization_id}` Lists all metadata for an organization.
- `/api/2/rest/package/{package_id}` Lists 

## Gotchas?

The value of `name` field can be used as the `id` parameter in requests.

In version 3, the `extras` field is an array populated with key-value objects, as in: 

```javascript
[{key: 'language', value: 'en'}, {key: ..., value: ...}]
```

which makes it a bit more difficult to parse. Version 1 & 2 store it "the proper way", with the keys being actual keys. 

## Portal specific

There is a [ckan-api-inspector](http://theodi.github.io/ckan-api-inspector) that helps see all the metadata fields that occur and their values. It helps see whether a field follows a pattern or can be populated by  (which many surprisingly are)

### data.gov

- needs POST request to access `/api/3/action/organization_show`
- doesn't support [`package_list`](https://github.com/GSA/data.gov/issues/295)
- one of the few sites that _tries_ to follow a schema: https://project-open-data.cio.gov/v1.1/schema/

### data.gov.uk
