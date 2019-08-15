import dto;
import ballerina/http;
import ballerina/io;

http:Client gateWay = new ("http://localhost:9090/sctgth");

public function main(string... args) {
    dto:Cities cities = {
        cities: [{
            name: "London",
            lat: "51.5073219",
            lng: "-0.1276474"
        }, {
            name: "HongKong",
            lat: "22.350627",
            lng: "114.1849161"
        }, {
            name: "Colombo",
            lat: "6.9349969",
            lng: "79.8538463"
        }]
    };

    json | error payload =json.constructFrom( cities);
    if (payload is json) {
        http:Request req = new;
        req.setJsonPayload(payload);
        http:Response | error post = gateWay->post("/getWeather", req);
        handleResponse(post);
    } else {
        io:println("error when creating the request." + payload.reason());
    }
}

function handleResponse(http:Response | error response) {
    if (response is http:Response) {
        var msg = response.getJsonPayload();
        if (msg is json) {
            //io:println(msg);
            dto:Response | error responses = dto:Response.constructFrom(msg);
            if (responses is dto:Response) {
                io:println(responses.wcity1.name + ":\n sunrise: " + responses.wcity1.response.results.sunrise + "\n"
                + " sunset: " + responses.wcity1.response.results.sunset);

                io:println(responses.wcity2.name + ":\n sunrise: " + responses.wcity2.response.results.sunrise + "\n"
                + " sunset: " + responses.wcity2.response.results.sunset);

                io:println(responses.wcity3.name + ":\n sunrise: " + responses.wcity3.response.results.sunrise + "\n"
                + " sunset: " + responses.wcity3.response.results.sunset);
            } else {
                io:println("error when converting to Response");
            }
        } else {
            io:println("Invalid payload received:", msg.reason());
        }
    } else {
        io:println("Error when calling the backend: ", response.reason());
    }
}
