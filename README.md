# esscrollsearch
elasticsearch scroll search

查询ES的数据导出到文件

背景: 
  emqtt console日志会自动滚动,仅保留最近五个文件,每个文件11M,导致原始日志备份困难,所以直接入库到ELK
  emqtt日志类型不统一,而且日志量巨大,所以没有做统一的字段拆分,但由于最近有些设备发生了轮询操作,想要在某个时间段根据SN号统计消息次数,因没有拆分字段无法分析,所以写了个脚本将日志导出到文件中,使用awk做

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

[root@prod-elasticsearch-master-01 ~]# more SearchResult-2019-07-10-1853.log 
"2019-07-10 11:09:16.870 [info] <0.2935.5465>@emqttd_server:trace:105 40001063000080BE/4000106300
0080BE@OGY0ZTRiMzVjMGNi PUBLISH to /OGY0ZTRiMzVjMGNi/clients/40001063000080BE/custom: <<\"{\\\"ti
mestamp\\\":1562728158252,\\\"action\\\":\\\"custom.message\\\",\\\"params\\\":\\\"{\\\\\\\"isMot
orWalkOn\\\\\\\":0}\\\"}\">>"
```
