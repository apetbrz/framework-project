FROM cimg/go:1.24.2-node
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --runtime dotnet --runtime aspnetcore --version 8.0.0
RUN echo '. ~/.cargo/env' >> $HOME/.profile
RUN echo 'export DOTNET_ROOT=$HOME/.dotnet' >> $HOME/.profile
RUN echo 'export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools' >> $HOME/.profile
COPY --chown=circleci axum_app/ ./axum_app/
COPY --chown=circleci dotnet_app/ ./dotnet_app/
COPY --chown=circleci express_app/ ./express_app/
COPY --chown=circleci gin_app/ ./gin_app/
COPY --chown=circleci test_scripts/ ./test_scripts/
COPY --chown=circleci serverlauncher.sh /usr/local/bin/runserver
RUN chmod -R 744 .
RUN chmod 744 /usr/local/bin/runserver
RUN npm install -gy pm2
RUN cd ./express_app && npm install
RUN echo 'echo "Welcome! Use runserver to start each server!"' >> $HOME/.profile
ENTRYPOINT ["/bin/bash", "-l", "-i"]
