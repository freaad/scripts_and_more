# Some Docker tidbits

## Running Visual Studio from Docker
Install Gtk packages first:

```
apt-get install -y libgtk2.0-0 libxss1 libgconf-2-4
```
Now install VS Code:
```
dpkg -i ./code_1.9.1-1486597190_amd64.deb
```
If it fails with missing dependencies, run this:
```
apt-get -f install
```
And run VS Code installer again.
If you are running as a root in Docker, specify user dir when launching VS Code:
```
code . --user-data-dir=/root/.vscode-root
```

## Conda, TensorFlow

TensorFlow works with Python 3.5 so need Anaconda 4.2, not higher.
```
bash ./Anaconda3-4.2.0-Linux-x86_64.sh 
conda create -n tensorflow
source activate tensorflow
pip install --ignore-installed --upgrade https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.0.0-cp35-cp35m-linux_x86_64.whl

```

## Udacity packages
```
pip install eventlet flask-socketio keras
```
