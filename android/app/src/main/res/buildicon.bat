ffmpeg -i .\icon.png -vf scale=72:72 .\mipmap-hdpi\ic_launcher.png -y
ffmpeg -i .\icon.png -vf scale=48:48 .\mipmap-mdpi\ic_launcher.png -y
ffmpeg -i .\icon.png -vf scale=96:96 .\mipmap-xhdpi\ic_launcher.png -y
ffmpeg -i .\icon.png -vf scale=144:144 .\mipmap-xxhdpi\ic_launcher.png -y
ffmpeg -i .\icon.png -vf scale=192:192 .\mipmap-xxxhdpi\ic_launcher.png -y