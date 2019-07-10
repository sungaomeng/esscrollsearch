# esscrollsearch
elasticsearch scroll search

查询ES的数据导出到文件

```
[root@prod-elasticsearch-master-01 ~]# sh scrollsearch.sh 
USAGE: scrollsearch.sh index filter searchfield starttime endtime
 e.g.: scrollsearch.sh logstash-mqtt.roo.bo-console-log-07.10 "custom.message AND OGY0ZTRiMzVjMGNi" "message" "20190710 11:00:00" "20190710 11:00:30"

[root@prod-elasticsearch-master-01 ~]# bash scrollsearch.sh logstash-mqtt.roo.bo-console-log-07.10 "custom.message AND OGY0ZTRiMzVjMGNi" "message" "20190710 11:00:00" "20190710 11:00:30"
A total of 110042 records are ready for export.
1000 records have been searched, please continue to wait .
······
111000 records have been searched, please continue to wait .
End of the query .
Total queries for 110042 ./SearchResult-2019-07-10-1844.log records , from ./SearchResult-2019-07-10-1844.log
```
