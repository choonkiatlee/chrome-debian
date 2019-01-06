FROM microsoft/dotnet:2.1-aspnetcore-runtime-stretch-slim

RUN apt-get update && apt-get install -y \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg \
	--no-install-recommends \
	&& curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& echo "deb https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
	&& apt-get update && apt-get install -y \
	google-chrome-stable \
	fontconfig \
	fonts-ipafont-gothic \
	fonts-wqy-zenhei \
	fonts-thai-tlwg \
	fonts-kacst \
	fonts-symbola \
	fonts-noto \
	ttf-freefont \
	--no-install-recommends \
	&& apt-get purge --auto-remove -y curl gnupg \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /src/*.deb


ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init


# Add user so we don't need --no-sandbox.
RUN groupadd -r scraper_user && useradd -r -g scraper_user -G audio,video scraper_user \
    && mkdir -p /home/scraper_user/Downloads \
    && chown -R scraper_user:scraper_user /home/scraper_user 

# Run everything after as non-privileged user.
USER scraper_user

ENTRYPOINT ["dumb-init", "--"]
CMD ["google-chrome-stable","--remote-debugging-port=3000 --remote-debugging-address=0.0.0.0 --headless"]

# Expose port 9222 for devtools
EXPOSE 3000
