
The vulnerability we found is also known as a blind SQL injection, as we can inject SQL logic, but cannot directly see or access any of our queries' output. We must therefore use indirect methods to determine the outcome of our queries, such as observing changes in the server's behavior or responses to different inputs. Fortunately, sqlmap can automate this task for us as it can directly access the WebSocket service on port 9091 , given that we provide it with the necessary parameters for its queries. 

```
sqlmap -u "ws://soc-player.soccer.htb:9091" --data '{"id": "*"}' --dbs --threads 10 -- level 5 --risk 3 --batch
```

After a few minutes sqlmap successfully dumps the database names, with the more interesting candidate being soccer_db . We can then directly target that database and dump its contents, using the -D and -- dump flags, respectively. 

```
sqlmap -u "ws://soc-player.soccer.htb:9091" --data '{"id": "*"}' --threads 10 -D soccer_db --dump --batch
```
