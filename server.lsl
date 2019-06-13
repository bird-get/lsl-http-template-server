#include "lsl-html-template-server/templates/index.html"
#include "lsl-html-template-server/templates/example_page_1.html"
#include "lsl-html-template-server/templates/example_page_2.html"

key requestURL;
string url;

string strReplace(string str, string search, string replace)
{
    return llDumpList2String(llParseStringKeepNulls((str = "") + str, [search], []), replace);
}

default
{
    state_entry() 
    {
        requestURL = llRequestURL();
    }
 
    http_request(key request_id, string method, string body) 
    {
        if((method == URL_REQUEST_GRANTED) && (request_id == requestURL))
        {
            llOwnerSay(body);
            url = body;
            requestURL = NULL_KEY;
        }
        else if((method == URL_REQUEST_DENIED) && (request_id == requestURL)) 
        {
            requestURL = NULL_KEY;
        }
        else if(method == "POST") 
        {
            // TODO Handle POST data in request body
            llHTTPResponse(request_id, 200, "Success");
        }
        else if(method == "GET")
        {
            llSetContentType(request_id, CONTENT_TYPE_HTML);
            string page = "";
            string path = llGetHTTPHeader(request_id, "x-path-info");

            if(path == "" || path == "/")
            {
                page = index_page;
            }
            else if(path == "/example_page_1")
            {
                page = example_page_1;
            }
            else if(path == "/example_page_2")
            {
                page = example_page_2;
            }

            page = strReplace(page, "{{ url }}", url);
            llHTTPResponse(request_id, 200, page);
        }
        else 
        {
            llHTTPResponse(request_id, 405, "Unsupported Method");
        }
    }
}
