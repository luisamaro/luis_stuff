#!/usr/bin/env bash

for m in $(curl -ks 'https://localhost:9200/index-migrations/migrations/_search?pretty' \
-d '{"from":0, "size":10000,"query":
  {"bool":
    {"must_not":
      {"term": {"merge.status.keyword":"complete-segments_1"}},
      "must":{"query_string":{"query": "complete-segments_*", "analyze_wildcard":true}}
    }
  }, "_source": {"excludes": ["move.metrics", "merge.metrics"]}}' \
-H 'content-type: application/json' | awk -F\" '/_id/{print $4}'); \
do echo "Dropping id: ${m}"; \
curl -ks -XDELETE "https://localhost:9200/index-migrations/migrations/${m}"; done
