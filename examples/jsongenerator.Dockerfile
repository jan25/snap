FROM rust:1.67

WORKDIR /src
COPY . .

RUN curl https://stedolan.github.io/jq/download/linux64/jq > /usr/bin/jq && chmod +x /usr/bin/jq

RUN git clone https://github.com/jsontypedef/json-typedef-infer.git
RUN cargo install --path json-typedef-infer
RUN git clone https://github.com/jsontypedef/json-typedef-fuzz.git
RUN cargo install --path json-typedef-fuzz

RUN echo '{ "name": "Joe", "age": 42 }' | jtd-infer | jtd-fuzz -n 1 > example.input
