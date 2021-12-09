FROM nikokozak/lector-rocky-base as build

RUN mkdir /lector
COPY server /lector
WORKDIR /lector

RUN source /root/.bashrc && \
   mix deps.get --only prod && \
   mix compile && \
   mix release --overwrite

# Make a release archive
RUN tar -zcf /lector/release.tar.gz -C /lector/_build/prod/rel/lector .

# Copy out
FROM scratch as export
COPY --from=build /lector/release.tar.gz .
