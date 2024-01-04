FILE=package.json

# This could be used to just auto clone
# You would use this like `cratovite ssh-url.git`
# uncomment these 3 lines to use it like that.

# reponame=${1##*/}
# reponame=${reponame%.git}

# git clone $1 && cd $reponame

# npm install
if test -f "$FILE"; then
    echo ""
    echo "========================{ $FILE exists. Installing }========================"
    npm install 
    else return;
fi

git checkout -b vite

# install vite stuff
npm install vite @vitejs/plugin-react vitest --save-dev

# uninstall cra stuff
npm uninstall react-scripts

# move index to root
mv public/index.html .

# make config file
touch vite.config.js

# write to vite.config.js
tee vite.config.js << END
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(() => {
    return {
        build: {
            outDir: 'build',
        },
        server: {
            proxy: {
                '/api':'http://localhost:5001',
            }
        },
        plugins: [react()],
    };
});
END

# change scripts in place

npm pkg set 'scripts.client'='vite'
npm pkg set 'scripts.build'='vite build'
npm pkg delete 'scripts.eject'




#  notify that the scripts need to be double checked
echo ""
echo "========================{ TODO }========================"
echo "check your package.json scripts!"
echo "eg: "scripts": {
        "start": "node server/server.js",
        "build": "vite build",
        "client": "vite",
        "server" : "nodemon server/server.js"
        } "

# rename all react files with .js extention to have .jsx
    # mv src/App.js src/App.jsx
    # mv src/index.js src/index.jsx
    (zmv 'src/(*).js' 'src/$1.jsx') || true

(zmv 'src/components/(*)/(*).js' 'src/components/$1/$2.jsx') || true


# remove all %PUBLIC_URL% from HTML file
    sed -i '' -e "s/\%PUBLIC_URL\%//g" ./index.html

# Add script to html
# Wow. Bash skill++
# <script type="module" src="/src/index.jsx"></script>
    sed -i '' '/<\/body>/i\
<script type="module" src="/src/index.jsx"></script>\
' index.html

#git stuff
    git add .
    git commit -m "migrate from CRA to Vite via script"
