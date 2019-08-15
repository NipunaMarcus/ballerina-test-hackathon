import dto;
import ballerina/http;
import ballerina/io;
import ballerina/log;

listener http:Listener ls = new (9090);
http:Client sunriseApi = new ("http://api.sunrise-sunset.org");

@http:ServiceConfig {
    basePath: "/sctgth"
}
service scatterGatherer on ls {
    @http:ResourceConfig {
        path: "getWeather",
        methods: ["POST"],
        body: "cities"
    }
    resource function getWeather(http:Caller caller, http:Request request, json cities) returns error? {
        io:println("in service");
        dto:Cities | error citiesList = dto:Cities.constructFrom(cities);
        dto:City city1 = {};
        dto:City city2 = {};
        dto:City city3 = {};

        if (citiesList is dto:Cities) {
            if (citiesList.cities.length() > 0) {
                city1 = citiesList.cities[0];
                city2 = citiesList.cities[1];
                city3 = citiesList.cities[2];
            }
        }

        fork {
            worker wcity1 returns json {
                (http:Response | error) result = sunriseApi->get("/json?lat=" + <@untainted>city1.lat + "&lng=" + <@untainted>city1.lng);
                json value = {name: city1.name, response: handleResponse(result, city1.name)};
                io:println("getCity1: " + value.toString());
                return value;
            }

            worker wcity2 returns json {
                (http:Response | error) result = sunriseApi->get("/json?lat=" + <@untainted>city2.lat + "&lng=" + <@untainted>city2.lng);
                json value = {name: city2.name, response: handleResponse(result, city2.name)};
                io:println("getCity2: " + value.toString());
                return value;
            }

            worker wcity3 returns json {
                (http:Response | error) result = sunriseApi->get("/json?lat=" + <@untainted>city3.lat + "&lng=" + <@untainted>city3.lng);
                json value = {name: city3.name, response: handleResponse(result, city3.name)};
                io:println("getCity3: " + value.toString());
                return value;
            }
        }

        record {
            json wcity1 = {};
            json wcity2 = {};
            json wcity3 = {};
        } results = wait {wcity1, wcity2, wcity3};

        json | error response =json.constructFrom( results);

        http:Response res = new;
        if (response is json) {
            res.setPayload(<@untiant>response);
        } else {
            res.statusCode = 500;
            res.setJsonPayload({"error111": <@untainted><string>response.detail()?.message});
        }

        var result = caller->respond(res);
        if (result is error) {
            log:printError("Error in responding", result);
        }
    }
}

function handleResponse(http:Response | error response, string city) returns @tainted json {
    io:println(city);
    if (response is http:Response) {
        var msg = response.getJsonPayload();
        if (msg is json) {
            return msg;
        } else {
            io:println("Invalid payload received:", msg.reason());
        }
    } else {
        io:println("Error when calling the backend: ", response.reason());
    }
    return {};
}
