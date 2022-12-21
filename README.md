# dockerforsh

```bash
sudo su - root
git clone git@github.com:gorunvm/dockerforsh.git

cd dockerforsh
./bin/docker init 172.20.0.1
./bin/docker run -d hello1 172.20.0.2 hello /bin/hello
curl  172.20.0.2
./bin/docker ps
./bin/docker exec hello1
./bin/docker stop hello1
```

[window10 multipass set staticIP](https://user-images.githubusercontent.com/115438438/208836969-0e51c101-e1a9-4479-ba12-c4901cb0782a.mp4)

[window10 install docker-cli](https://user-images.githubusercontent.com/115438438/208836983-85baa9f2-5f7c-44ad-abfb-94ef7d5b9fb3.mp4)

