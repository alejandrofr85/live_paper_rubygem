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
    "URL": "url"
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
    "dateCreated":"2014-10-07T20:57:01.083+0000",
    "dateModified":"2014-10-07T20:57:01.083+0000",
    "link":[
      {
        "rel":"self",
        "href":"/api/v1/payoffs/payoff_id"
      },
      {
        "rel":"analytics",
        "href":"/analytics/v1/payoffs/payoff_id"
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

def lpp_trigger_response_json
  <<-RESPONSE
{
  "trigger": {
    "id": "trigger_id",
    "name": "name",
    "watermark": "watermark",
    "link": [{"rel":"image", "href": "https://fileapi/id/image"}],
    "subscription": "subscription"
  }
}
  RESPONSE
end

def lpp_link_response_json
  <<-RESPONSE
{
  "link": {
    "id": "link_id",
    "name": "name",
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