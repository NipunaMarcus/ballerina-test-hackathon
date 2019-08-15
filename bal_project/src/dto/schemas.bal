public type City record {
    string name = "";
    string lat = "";
    string lng = "";
};

public type Cities record {
    City[] cities = [];
};

public type Response record {
    record {
        string name;
        record {
            record {
                string sunrise;
                string sunset;
            } results;
        } response;
    } wcity1;

    record {
        string name;
        record {
            record {
                string sunrise;
                string sunset;
            } results;
        } response;
    } wcity2;

    record {
        string name;
        record {
            record {
                string sunrise;
                string sunset;
            } results;
        } response;
    } wcity3;
};
