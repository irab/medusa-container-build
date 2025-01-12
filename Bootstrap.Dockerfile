FROM registry.gitlab.com/gitlab-ci-utils/curl-jq:latest
COPY create-publishable-key.sh /create-publishable-key.sh
RUN chmod +x /create-publishable-key.sh 