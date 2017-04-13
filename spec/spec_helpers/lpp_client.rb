def lpp_auth_response_json
  <<-RESPONSE
{
"serviceName":"auth",
"apiVersion":"1.0",
"accessToken":"SECRETTOKEN",
"scope":"default"
}
  RESPONSE
end

def lpp_payoff_response_json
  <<-RESPONSE
{
  "payoff": {
    "id": "payoff_id",
    "name": "name",
    "type": "url",
    "url": "url"
  }
}
  RESPONSE
end

def lpp_richpayoff_response_json
  <<-RESPONSE
{
  "payoff": {
    "id": "payoff_id",
    "name": "name",
    "type": "richPayoff",
    "dateCreated":"2014-10-07T20:57:01.083+0000",
    "dateModified":"2014-10-07T20:57:01.083+0000",
    "link":[
      {
        "rel":"self",
        "href":"/api/v2/payoffs/payoff_id"
      },
      {
        "rel":"analytics",
        "href":"/analytics/v2/payoffs/payoff_id"
      }
    ],
    "richPayoff" : {
      "version": 1,
      "public": {
        "url": "url"
      },
      "private": {
        "content-type": "data_type",
        "data": "#{Base64.encode64('{ "field": 1 }').gsub(/\n/,'')}"
      }
    }
  }
}
  RESPONSE
end

def lpp_trigger_response_json(type='watermark')
  <<-RESPONSE
{
  "trigger": {
    "id": "trigger_id",
    "name": "name",
        "dateCreated": "2014-10-08T22:06:28.518+0000",
        "dateModified": "2014-10-08T22:06:28.518+0000",
    "link": [
      {"rel":"self", "href": "https://www.livepaperapi.com/api/v2/triggers/trigger_id"},
      {"rel":"analytics", "href": "https://www.livepaperapi.com/analytics/v2/triggers/trigger_id"},
      {"rel":"download", "href": "https://fileapi/trigger_id/image"},
      {"rel":"shortURL", "href": "http://hpgo.co/abc123"}
    ],
    "state": "ACTIVE",
    "type": "#{type}",
    "startDate":"2014-10-08T20:40:26.376+0000",
    "endDate":"2015-10-09T02:29:12.376+0000"
  }
}
  RESPONSE
end

def lpp_link_response_json(name='name')
  <<-RESPONSE
{
  "link": {
    "id": "link_id",
    "name": "#{name}",
    "dateCreated": "2014-04-08T08:16:25.723+0000",
    "dateModified": "2014-04-08T08:16:25.723+0000",
    "link": [{
      "rel": "self",
      "href": "self_url"
    },
    {
      "rel": "analytics",
      "href": "analytic_url"
    },
    {
      "rel": "payoff",
      "href": "payoff_url"
    },
    {
      "rel": "trigger",
      "href": "trigger_url"
    }],
    "payoffId": "payoff_id",
    "triggerId": "trigger_id"
  }
}
  RESPONSE
end

def lpp_watermark_response
  'watermark_data'
end

def lpp_delete_error_response
  <<-RESPONSE
{ "associatedLinks": "1",
  "link": [{
      "rel": "associatedLinks",
      "href": "https://dev.livepaperapi.com/api/v2/links?trigger=my_trigger_id"
  }],
  "error": {
      "title": "409 Conflict",
      "message": "The trigger to be deleted has associated links. The associated links must be deleted first."
  }
}
  RESPONSE

end
