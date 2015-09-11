# Notes on CKAN API

## General

There are 3 versions of the API (1,2 and 3), documented [here](http://docs.ckan.org/en/latest/api/index.html). Things we mostly use (at moment of writing):

---

##### `/api/3/action/package_show?id={package_id}`
Provides all metadata for a package/dataset. We only use this _sometimes_ to get the `id` of the dataset, and then request all data via the old `/api/2/rest/package`.

---

##### `/api/2/rest/package/{package_id}`
An older version and slightly different.

###### Differences between v2 & v3:

1. Metadata in v3 is in the `result` field, whereas in v2 metadata is the response itself
2. `extras` field contains an array of key-value hashes in v3 (`[{ key: "id", value: 1 }]`), whereas in v2 it is a hash (`{id: 1}`)

---

##### `/api/3/action/organization_show?id={organization_id}`
Provides all metadata for an organization.

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

- needs POST request to access `/api/3/action/organization_show?id={organization_id}`, but provides painless way to organization metadata via `api/2/rest/group/{organization_id}`. Haven't found any other CKAN site that provides organization through API v2
- doesn't support `package_list` ([Github issue](https://github.com/GSA/data.gov/issues/295))
- one of the few sites that _tries_ to follow a schema https://project-open-data.cio.gov/v1.1/schema/ but often field values would not match it
- Provides some harvesting metadata which tends to follow a standard schema (["As part of Project Open Data most government offices are transitioning to make all of their metadata available via a standard schema"](https://www.data.gov/developers/harvesting)).

### data.gov.uk
