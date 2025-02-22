
## No SQL Expertise? No Problem!

You have a Swiss Army knife for SQL queries!

By providing the right context for a specific database—not the data itself, but the structure, including metadata about the database schema—you can effortlessly generate accurate SQL queries.

Specifically, the following information would be helpful:

1. List of Tables

    The names of all tables in the database.

2. Table Structures (Schema)

    Column names and their data types (e.g., INTEGER, TEXT, REAL, BLOB).
    Primary keys and foreign keys (relationships between tables).
    Constraints (e.g., NOT NULL, UNIQUE, DEFAULT values).

3. Indexes

    Any indexes created on columns (helps optimize queries).

4. Relationships Between Tables

    If there are foreign keys, which tables are linked and how.
    Cardinality (one-to-many, many-to-many).

5. Sample Queries (Optional)

    Example queries (if available) to understand common patterns.

How to Retrieve This Information from SQLite

If you have access to the database, you can extract this metadata using SQL queries:

List Tables:

```
SELECT name FROM sqlite_master WHERE type='table';

```
Get Table Structure:

```
PRAGMA table_info(your_table_name);

```
List Foreign Keys of a Table:

```
PRAGMA foreign_key_list(your_table_name);

```
List Indexes:

```
PRAGMA index_list(your_table_name);

```
Describe Entire Database Schema:

```
SELECT sql FROM sqlite_master WHERE type IN ('table', 'index', 'view');

```
In practice  you need  couple of python fiuncions which automatase the whole process


```
import sqlite3
#=============================================================================================================================
# this funcion  generates  file which contains good context for LLM to be able create sql queries and answer your questions
#==============================================================================================================================
def get_database_metadata(db_path, output_file):
    # Connect to SQLite database
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(f"# SQLite Database Metadata\n\n")
        
        # Get list of tables
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
        tables = [row[0] for row in cursor.fetchall()]
        
        f.write("## Tables\n\n")
        for table in tables:
            f.write(f"### Table: `{table}`\n\n")
            
            # Get table structure
            cursor.execute(f"PRAGMA table_info({table})")
            columns = cursor.fetchall()
            f.write("#### Columns:\n\n")
            f.write("| Column Name | Type | Not Null | Default Value | Primary Key |\n")
            f.write("|-------------|------|----------|--------------|-------------|\n")
            for col in columns:
                f.write(f"| {col[1]} | {col[2]} | {col[3]} | {col[4]} | {col[5]} |\n")
            f.write("\n")
            
            # Get foreign keys
            cursor.execute(f"PRAGMA foreign_key_list({table})")
            foreign_keys = cursor.fetchall()
            if foreign_keys:
                f.write("#### Foreign Keys:\n\n")
                f.write("| Column | References Table | References Column |\n")
                f.write("|--------|----------------|------------------|\n")
                for fk in foreign_keys:
                    f.write(f"| {fk[3]} | {fk[2]} | {fk[4]} |\n")
                f.write("\n")
            
            # Get indexes
            cursor.execute(f"PRAGMA index_list({table})")
            indexes = cursor.fetchall()
            if indexes:
                f.write("#### Indexes:\n\n")
                f.write("| Index Name | Unique |\n")
                f.write("|------------|--------|\n")
                for index in indexes:
                    f.write(f"| {index[1]} | {index[2]} |\n")
                f.write("\n")
        
        # Get views
        cursor.execute("SELECT name, sql FROM sqlite_master WHERE type='view'")
        views = cursor.fetchall()
        if views:
            f.write("## Views\n\n")
            for view in views:
                f.write(f"### View: `{view[0]}`\n\n```{view[1]}```\n")
        
        # Get entire database schema
        f.write("## Entire Database Schema\n\n")
        cursor.execute("SELECT sql FROM sqlite_master WHERE type IN ('table', 'index', 'view')")
        schema_entries = cursor.fetchall()
        for schema in schema_entries:
            if schema[0]:
                f.write(f"```{schema[0]}```\n")
    
    conn.close()
    print(f"Metadata written to {output_file}")



```
### Example usage

```
get_database_metadata("your_database.sqlite", "database_metadata.md")
```

## Effortlessly Turn Your Questions into SQL Queries with AI

I've been using Domoticz mainly through the GUI, but now I want to dive deeper and explore its SQLite database.

The challenge? There's little detailed information about the database structure—especially since everyone has a unique setup with different sensors, devices, and hardware.

This is where an LLM-powered assistant becomes a game-changer, effortlessly translating human questions into precise SQL queries!


```
def call_api(messages, model="gpt-4o-mini-2024-07-18", max_tokens=100):
    response = client.chat.completions.create(
        model=model,
        messages=messages,
        max_tokens=max_tokens
    )

    return response.choices[0].message.content

```

sytem prompt  and context are  really important so LLM do the staff 
```

def ask_sql_expert_struct(what_user_ask):

    system_prompt = f"""
    
    You are a master in working/creating/interpreting   SQLLite and SQLLite  requests, techniques  you could create  SQLLite request based on short description given as an input 
    in human  natural language . You will be perfect asistent understanding most of the sql commands 
    
    - before Every created SQLLite request always will placed  magic %%sql
    - sql code should be readable
    - sql code should be  good formated with indents, new lines, etc
    - sql code should contain options to sort out results ie ORDER BY name; if that sorting out is apprpiate for  particular user request
    - sql code  should not contain extra formating signs so user could directly copy it and use it 

    Example of the good results is:

    %%sql

    SELECT * 
    FROM `orders`
    LIMIT 10

    All table, index, and view definitions and  "Entire Database Schema" section are inside database_metadata.md: {database_metadata}


      
    Additionally after  creating request you will be explaining each line with simple natural language what you are doing/
    that will be useful for  the user to learn easly and understand SQL sytax.
    Present explanation differentiating code/synthax by color compared to explanations
    At the end suggest if necessary  diffrent approach withch give more detailed or more simplified 
    results.
    
    

    """
    
    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": what_user_ask}
    ]
    
    print( call_api(messages, max_tokens=1000) )

```

```
what_user_ask="""basend on the schema and all available information take some last 20 records  for device ID =1 from Temperature table considering time as an order and display all values of those records 
`"""
ask_sql_expert_struct(what_user_ask)

```
LLM answer was :

```
%%sql

SELECT * 
FROM `Temperature`
WHERE `DeviceRowID` = 1
ORDER BY `Date` DESC
LIMIT 20

---

In this SQL query:

- **SELECT *:** This part tells the database to select all columns from the specified table.
- **FROM `Temperature`:** This specifies that we are retrieving data from the `Temperature` table.
- **WHERE `DeviceRowID` = 1:** This condition filters the results to only include records where the `DeviceRowID` is equal to 1.
- **ORDER BY `Date` DESC:** This orders the results by the `Date` column in descending order, meaning the most recent records will appear first.
- **LIMIT 20:** This limits the results to the last 20 records that meet the criteria.

This query will give you the last 20 temperature records for the device with ID 1, sorted by the most recent date. If you need more specific information or a different sorting method, please let me know!
```
I executed given query and got answer( here only 8 rows just to show in reality was 20)
```
 * sqlite:///../temp/Domoticz.db
Done.

DeviceRowID 	Temperature 	Chill 	Humidity 	Barometer 	DewPoint 	SetPoint 	Date
1 	37.0 	0.0 	0 	0 	0.0 	0.0 	2024-12-12 10:45:00
1 	38.1 	0.0 	0 	0 	0.0 	0.0 	2024-12-12 10:40:00
1 	38.6 	0.0 	0 	0 	0.0 	0.0 	2024-12-12 10:35:00
1 	36.5 	0.0 	0 	0 	0.0 	0.0 	2024-12-12 10:30:00
1 	37.0 	0.0 	0 	0 	0.0 	0.0 	2024-12-12 10:25:00
1 	37.0 	0.0 	0 	0 	0.0 	0.0 	2024-12-12 10:20:00
1 	37.0 	0.0 	0 	0 	0.0 	0.0 	2024-12-12 10:15:00
1 	37.6 	0.0 	0 	0 	0.0 	0.0 	2024-12-12 10:10:00
1 	37.0 	0.0 	0 	0 	0.0 	0.0 	2024-12-12 10:05:00

```

### If you want more info
lencz.sla@gmail.com


