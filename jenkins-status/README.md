### Jenkinsni Monitoring qilish uchun web dastur

Muammo: Muammo shunda ediki bizda Jenkins bor va biz Jenkinsni monitoring qilib turishimiz kerak edi biz buni web dastur yozish orqali muammoga yechim berdik. Dastur hozir juda oddiy bu rivojlantiriladi.
Dastur Jenkins API dan foydalangan holda barcha statusni ko'radi. Dastur ishlab turgan ishlamay qolgan va ishlab turganligini real vaqtda ko'rsatib turadi. Dastur har 2 sekunda ma'lumotlarni yangilab turadi.

![alt text](https://github.com/ismoilovdevml/devops-tools/blob/master/jenkins-status/assets/jenkins-status3.png)
![alt text](https://github.com/ismoilovdevml/devops-tools/blob/master/jenkins-status/assets/jenkins-status4.png)
![alt text](https://github.com/ismoilovdevml/devops-tools/blob/master/jenkins-status/assets/jenkins-status2.png)
![alt text](https://github.com/ismoilovdevml/devops-tools/blob/master/jenkins-status/assets/jenkins-status1.png)

Dastur python dasturlash tilining Flask fremworkidan foydalanib yasalgan.

Dasturni ishga tushirish uchu sizda python o'rnatilgan bo'lishi kerak

Dasturni konfigratsiya qilib o'zingizning jenkins url mazilini kiritishingiz kerak

![alt text](https://github.com/ismoilovdevml/devops-tools/blob/master/jenkins-status/assets/image.png)



Ishga tushirish

```bash
git clone https://github.com/ismoilovdevml/devops-tools.git
cd devops-tools/jenkins-status
python app.py
```

Dastur http://127.0.0.1:5000 url mazilida ishlaydi

## Docker bilan ishga tushirish

```bash
git clone https://github.com/ismoilovdevml/devops-tools.git
cd devops-tools/jenkins-status
sudo su
sudo docker build -t jenkins-status .
sudo docker run -p 5000:5000 jenkins-status
```

Bu dastur tizim ip addresining `5000` portida ishlaydi.

```python
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```
