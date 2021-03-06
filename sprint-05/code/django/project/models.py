from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User
from django.urls import reverse
from PIL import Image

# Create your models here.
class Post(models.Model):
    title = models.CharField(max_length=100)
    image = models.ImageField(upload_to='post_pics', null=True)
    content = models.TextField()
    date_posted = models.DateTimeField(default=timezone.now)
    author = models.ForeignKey(User, on_delete=models.CASCADE)

    def __str__(self):
        return self.title

    def get_absolute_url(self):
        return reverse("post-detail", kwargs={'pk': self.pk})
    
class Comment(models.Model):
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name='comments')
    name = models.CharField(max_length=80)
    email = models.EmailField()
    body = models.TextField()
    created_on = models.DateTimeField(auto_now_add=True)
    active = models.BooleanField(default=False)

    class Meta:
        ordering = ['created_on']
    
    def __str__(self):
        return 'Comment {} by {}'.format(self.body, self.name)
        
class Karma(models.Model):
    name = models.CharField(max_length=80)
    karma = models.FloatField()
    rated_on = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title