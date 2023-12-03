# Week 1 — App Containerization

Create Docker file

```
FROM python:3.10-slim-buster

WORKDIR /backend-flask

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

ENV FLASK_ENV=development

EXPOSE ${PORT}
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]
```

## Build image
```
docker build -t backend-flask ./backend-flask
```

## Run Docker image
```
docker run --rm -p 4567:4567 -it backend-flask

# rm : remove the container when it exits (short-term containers)
# p 4567:4567 : maps the port on host machine with the container ports ( host:container)
# i : attach the container as an interactive container 
# t : which allocates it a pseudo-TTY (pseudoTerminal)
```

## Here we need to set FRONTENT_URL and BACKEND_URL for now atleast Week-1
```
#implicit
docker run --rm -p 4567:4567 -it -e BACKEND_URL='*' FRONTEND_URL='*' backend-flask

# get it piped from local host
export BACKEND_URL='*'
export FRONTEND_URL='*'
docker run --rm -p 4567:4567 -it -e BACKEND_URL -e FRONTENT_URL backend-flask
```


## Write docker container cmd to run
```
#docker exec -it <container-id> <command>

# This opens bash shell and now you can do things on container terminal
docker exec -it 1d58 bash
```

## Get local docker images
```
docker images ls
```

## Get Running docker containers
```
docker ps [ -f <filter_key: filter_value>] [-a]

# ps - process status
# f - filter
# filter_key : filter_value :: image : image_name
# a : shows containers in all status (dead/exited as well)
```

## Check if you get the data
```
append following (/api/activities/home) to URL
```

## Remove a stopped container
```
docker rm <container-id>
```

## Remove a running container
```
docker stop <container-id> && docker rm <container-id>
```

## Create a Dockerfile for front-end
```
version: "3.8"
services:
  backend-flask:
    environment:
      FRONTEND_URL: "https://3000-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
      BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./backend-flask
    ports:
      - "4567:4567"
    volumes:
      - ./backend-flask:/backend-flask
  frontend-react-js:
    environment:
      REACT_APP_BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./frontend-react-js
    ports:
      - "3000:3000"
    volumes:
      - ./frontend-react-js:/frontend-react-js

# the name flag is a hack to change the default prepend folder
# name when outputting the image names
networks: 
  internal-network:
    driver: bridge
    name: cruddur
```

## Now we need to run both the containers and for that we need docker compose file mentioning which containers to run and which dockerfile to use to spin up those containers

## Create `docker-compose.yml` at the root folder
```
version: "3.8"
services:
  backend-flask:
    environment:
      FRONTEND_URL: "https://3000-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
      BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./backend-flask
    ports:
      - "4567:4567"
    volumes:
      - ./backend-flask:/backend-flask
  frontend-react-js:
    environment:
      REACT_APP_BACKEND_URL: "https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
    build: ./frontend-react-js
    ports:
      - "3000:3000"
    volumes:
      - ./frontend-react-js:/frontend-react-js

# the name flag is a hack to change the default prepend folder
# name when outputting the image names
networks: 
  internal-network:
    driver: bridge
    name: cruddur
```

## Now to build the docker containers using docker compose
```
docker compose -f "file_name.yml" up -d --build

# d : run in background
# build: this tells the docker to build the images for the containers before running them. Else, it assumes that all images needed are in existence.
```

### Traditionally docker-compose was a different entity hence, two commands for same operations docker-compose. 
- Currentyl when we use `docker-compose`, another docker module named `docker-extension` comes into play where it is responsible for  converting docker-compose process to `docker` module's submodule `compose`.
- Inshort; `docker-compose` uses executable directly and `docker compose` treats it as a plugin.

``` 
docker-compose -f "file_name.yml" up -d --build

# d : run in background
# build: this tells the docker to build the images for the containers before running them. Else, it assumes that all images needed are in existence.
```

### Add a new api path `/api/activities/notification` under open api yml file under backend-flask

- Use the OpenApi plugin on vscode. Tap the plugin to see the api routes when the file is open and in active state in editor.
- Rt. click add new path and edit the yaml file.

```yaml
  /api/activities/notifications:
    get:
      description: 'Return a feed of activity for all of my following identities'
      tags:
        - activities
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Activity'
```
- Here the `tags: activities` is used to group them under the api routes.
- To check the api routes click top right on the editor - ( Open Preview ) on vscode.

### Create a new route under `./backend-flask/app.y` ( here: /api/activities/notifications)

```
@app.route("/api/activities/notifications", methods=['GET'])
def data_notification():
  data = NotificationActivities.run()
  return data, 200
```

### Create path on frontend as well for `/notifications`:
- Add new path on `app.js` under react-router
```
{
    path: "/notifications",
    element: <NotificationsFeedPage />
}
```
- Create `NotificationFeedPage.js` and `NotificationFeedPage.css` and return a hardcoded response.(Copy from HomeFeedPage)

### Working on database

- Create container config for `dynamodb` as well as `postgres` under docker-compose
(Append following to the services array under docker compose file)
```
  dynamodb-local:
    # https://stackoverflow.com/questions/67533058/persist-local-dynamodb-data-in-volumes-lack-permission-unable-to-open-databa
    # We needed to add user:root to get this working.
    user: root
    command: "-jar DynamoDBLocal.jar -sharedDb -dbPath ./data"
    image: "amazon/dynamodb-local:latest"
    container_name: dynamodb-local
    ports:
      - "8000:8000"
    volumes:
      - "./docker/dynamodb:/home/dynamodblocal/data"
    working_dir: /home/dynamodblocal
  db:
    image: postgres:13-alpine
    restart: always
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    ports:
      - '5432:5432'
    volumes: 
      - db:/var/lib/postgresql/data

# the name flag is a hack to change the default prepend folder
# name when outputting the image names
networks: 
  internal-network:
    driver: bridge
    name: cruddur
volumes:
  db:
    driver: local
```

### Add a service named `notification_activities.py` to mock data to the api response.

```
from datetime import datetime, timedelta, timezone
class NotificationActivities:
  def run():
    now = datetime.now(timezone.utc).astimezone()
    results = [{
      'uuid': '68f126b0-1ceb-4a33-88be-d90fa7109eee',
      'handle':  'James Spurin',
      'message': 'Cloud is cloudy!',
      'created_at': (now - timedelta(days=2)).isoformat(),
      'expires_at': (now + timedelta(days=5)).isoformat(),
      'likes_count': 5,
      'replies_count': 1,
      'reposts_count': 0,
      'replies': [{
        'uuid': '26e12864-1c26-5c3a-9658-97a10f8fea67',
        'reply_to_activity_uuid': '68f126b0-1ceb-4a33-88be-d90fa7109eee',
        'handle':  'Worf',
        'message': 'This post has no honor!',
        'likes_count': 0,
        'replies_count': 0,
        'reposts_count': 0,
        'created_at': (now - timedelta(days=2)).isoformat()
      }],
    },
    ]
    return results
```

### Just to test the dynamodb local 

- Create Table
```
aws dynamodb create-table \
    --endpoint-url http://localhost:8000 \
    --table-name Music \
    --attribute-definitions \
        AttributeName=Artist,AttributeType=S \
        AttributeName=SongTitle,AttributeType=S \
    --key-schema AttributeName=Artist,KeyType=HASH AttributeName=SongTitle,KeyType=RANGE \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
    --table-class STANDARD
```

- Create an Item
```
aws dynamodb put-item \
    --endpoint-url http://localhost:8000 \
    --table-name Music \
    --item \
        '{"Artist": {"S": "No One You Know"}, "SongTitle": {"S": "Call Me Today"}, "AlbumTitle": {"S": "Somewhat Famous"}}' \
    --return-consumed-capacity TOTAL  
```

- List tables
```
aws dynamodb list-tables --endpoint-url http://localhost:8000
```

```
aws dynamodb delete-table --endpoint-url http://localhost:8000 --table-name Music
```

## Logging to Postgres client

```
psql -U <username> -h <hostname> 

# psql -U postgres -h localhost
```

#### Homework
- Push and tag an image
- Use multi-stage dockerfile
- Implement a healthcheck in the docker compose file.