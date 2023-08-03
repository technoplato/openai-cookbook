import sqlite3


def main():
    db_path = "wwdc_data.db"  # Update the path if needed
    conn = sqlite3.connect(db_path)

    cursor = conn.execute("SELECT * FROM urls LIMIT 3;")

    print("First 3 rows of the 'urls' table:")
    for row in cursor:
        print(row)

    conn.close()


if __name__ == "__main__":
    main()
