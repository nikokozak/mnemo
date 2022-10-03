## Sets up DB depending on env - seeds, etc.

while ! pg_isready -q -h $PGHOST -p $PGPORT -U $PGUSER
do
    echo "$(date) - waiting for db to start"
done

if [[ -z `psql -Atqc "\\list $PGDATABASE"` ]]; then
    echo "Database $PGDATABASE does not exist. Creating..."
    createdb -E UTF8 $PGDATABASE -l en_US.UTF-8 -T template0
    mix ecto.migrate
    mix run priv/repo/seeds.exs
    echo "Database $PGDATABASE created."
fi

exec MIX_ENV=prod mix phx.server
