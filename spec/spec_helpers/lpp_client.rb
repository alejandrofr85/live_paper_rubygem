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
    "richPayoff" : {
      "version": 1,
      "private": {
        "content-type": "data_type",
        "data": "#{Base64.encode64('{ "field": 1 }').gsub(/\n/,'')}"
      },
      "public": {
        "url": "url"
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
    "triggerId": "trigger_id",
    "payoffId": "payoff_id",
    "link": [{"rel":"analytics", "href": "analytics"}]
  }
}
  RESPONSE
end

def lpp_watermark_response
  'watermark_data'
end