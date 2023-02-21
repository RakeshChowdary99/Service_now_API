"""Template robot with Python."""
import requests
#import json
from requests.auth import HTTPBasicAuth
def minimal_task(username,pasw,query):
    authe = HTTPBasicAuth(username, pasw)
    x=requests.get('https://yashtechnologiespvtltddemo1.service-now.com/api/now/table/incident?sysparm_query='+query, auth=authe)
    print(type(x.text))
    #jobject=json.loads(x.text)
    #print(jobject)*/
    return(x.text,x.status_code)
    #f_object=open("file.txt","w+")
    #f_object.write(x.text)
    #f_object.close
if __name__ == "__main__":
    a=minimal_task()
