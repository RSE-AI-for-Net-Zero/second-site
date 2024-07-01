from celery import Celery
import os

host = os.getenv('RABBIT_IPV4')
print(host)

broker='amqp://second-site:generate_me_instead@' + host + ':5672/vh1'
app = Celery('tasks', broker=broker)
@app.task
def add(x, y):
    return x + y



