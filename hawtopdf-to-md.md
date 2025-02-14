
Here’s a lightweight Dockerfile and a Python script to process PDF files in the current directory and convert them to Markdown using LlamaParse. 

 Dockerfile
```

# Use a lightweight Python base image
FROM python:3.10-slim

# Set a dedicated directory for the script inside the container
WORKDIR /script

# Install necessary dependencies
RUN pip install --no-cache-dir llama-index pymupdf

# Copy the script into the container (keeps it separate from user files)
COPY convert.py /script/convert.py

# Set a different directory for processing PDFs
WORKDIR /data

# Run the script with the mounted volume
ENTRYPOINT ["python", "/script/convert.py"]

```

convert.py
```
import os
from llama_index.core.node_parser import SimpleNodeParser
from llama_index.core import SimpleDirectoryReader

# Get all PDF files in the mounted directory (/data)
pdf_files = [f for f in os.listdir(".") if f.endswith(".pdf")]

if not pdf_files:
    print("❌ No PDF files found in the current directory.")
    exit(1)

for pdf_file in pdf_files:
    print(f"📂 Loading {pdf_file}...")

    # Load the PDF
    documents = SimpleDirectoryReader(input_files=[pdf_file]).load_data()
    print(f"✅ {pdf_file} loaded. {len(documents)} document(s) found.")

    # Parse document into nodes
    parser = SimpleNodeParser()
    nodes = parser.get_nodes_from_documents(documents)

    print(f"🔄 Converting {pdf_file} to Markdown...")

    # Convert nodes to Markdown format
    markdown_output = "\n\n".join([node.get_text() for node in nodes])

    # Save to a Markdown file
    output_file = pdf_file.replace(".pdf", ".md")
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(markdown_output)

    print(f"✅ Done! {pdf_file} -> {output_file}\n")

print("🎉 All PDFs have been converted!")
```



    The script is stored separately in /script/convert.py inside the container.
    The current directory ($(pwd)) is only mounted to /data, so it doesn’t overwrite /script.
    The script runs in /data where PDFs are mounted.



============================

How to Build and Run
1️⃣ Build the Docker Image
```
docker build -t pdf-to-md .
```
2️⃣ Run the Container (Mounting Only PDFs)
```

docker run --rm --name pdf_converter --cpus="2" -v "$(pwd):/data" pdf-to-md
```
Explanation of Flags:

    --rm → Automatically remove the container after it stops.
    --name pdf_converter → Assigns a custom name to the container (pdf_converter).
    --cpus="2" → Limits the container to 2 CPU cores.
    -v "$(pwd):/data" → Mounts the current directory into /data inside the container.

```😊
