[root@prod-elasticsearch-master-01 ~]# cat scrollsearch.sh 
#!/bin/bash

#ES地址
ES="http://prod-elasticsearch-master-01:9200"
#索引名称
Index=$1
#搜索条件
Filter=$2
#查询文档开始时间
StartTime=`date -d "$4" +%s`000
#查询文档结束时间
EndTime=`date -d "$5" +%s`000
#保留的字段
SearchField="$3"
#设置单页查询条数
Size=1000
#查询结果在ES上下文中保留的时间,超出时间将查不到后续结果
RTime="1m"
#保留结果的文件
ResultFile="./SearchResult-`date +%F-%H%M`.log"

if [ $# != 5 ] ; then 
echo "USAGE: bash $0 index filter searchfield starttime endtime" 
echo " e.g.: bash $0 logstash-mqtt.roo.bo-console-log-07.10 \"custom.message AND OGY0ZTRiMzVjMGNi\" \"message\" \"20190710 11:00:00\" \"20190710 11:00:30\"" 
exit 1; 
fi 

#定义查询语句,发起深度分页查询
Search () {
    curl -s "$ES/$Index/_search?pretty&scroll=$RTime" -d '{
        "size":"'"$Size"'",
        "query":{
            "bool":{
                "must":[
                    {
                        "query_string":{
                            "query":"'"$Filter"'",
                            "analyze_wildcard":true
                        }
                    },
                    {
                        "range":{
                            "@timestamp":{
                                "gte":"'"$StartTime"'",
                                "lte":"'"$EndTime"'",
                                "format":"epoch_millis"
                            }
                        }
                    }
                ],
                "must_not":[
    
                ]
            }
        },
        "_source":{
            "excludes":[
            ]
         }
        },
    #打开aggs字段将会以时间为间隔显示每个时间段出现的总次数
    #    "aggs":{
    #        "2":{
    #            "date_histogram":{
    #                "field":"@timestamp",
    #                "interval":"1m",
    #                "time_zone":"Asia/Shanghai",
    #                "min_doc_count":1
    #            }
    #        }
    #    },
        "highlight": {
            "fields" : {
                "summary" : {}
            }
        }
    }'
}


#获取分页查询的结果
ScrollSearch () {
    curl -s "$ES/_search/scroll" -d '{
        "scroll":"'"$RTime"'",
        "scroll_id":'"$ScrollId"'

    }'
}

#创建ScrollSearch
SearchResult=`Search`
#截取总条数
ScrollCount=`echo $SearchResult |jq .hits.total`
echo "A total of $ScrollCount records are ready for export."
#截取ScrollId
ScrollId=`echo $SearchResult |jq ._scroll_id`
#将第一次search的结果也输出到文件中
echo $SearchResult | jq .hits.hits[]._source.message >> $ResultFile && echo "$Size records have been searched, please continue to wait ."

#循环查询ScrollSearch的结果,直至结果全部查询出来
Num=$Size
while :
do
    Result=`ScrollSearch`
    if [ $(echo $Result|jq .hits.hits[]|wc -l) -eq 0 ];then
        echo "End of the query ." 
        CountNum=`wc -l $ResultFile`
        echo "Total queries for $CountNum records , from $ResultFile"
        exit 3
    else
        let Num+=$Size
        echo $Result | jq .hits.hits[]._source.$SearchField >> $ResultFile
        echo "$Num records have been searched, please continue to wait ."
    fi
done
