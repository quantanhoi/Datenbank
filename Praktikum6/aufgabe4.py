import os
import datetime
import psycopg2
import sqlalchemy.exc
from sqlalchemy import *
from sqlalchemy.dialects.postgresql import Any
from sqlalchemy.orm import declarative_base, relationship, sessionmaker
'''cmd = 'psql -h 141.100.70.93 -U test_user1 -d sttrthie -f droptable4.sql'
os.system(cmd)'''
hostn1ame = "postgres.fbi.h-da.de"
database = "sttrthie"
user = "test_user1"
pwd = "1234"
server = "141.100.70.93"

engine = create_engine(f"postgresql+psycopg2://{user}:{pwd}@{server}/{database}", echo=True)
Base = declarative_base()
Session = sessionmaker(bind=engine)
session = Session()
connection = engine.connect()
metadata = MetaData()


class Studio(Base):
    __tablename__ = 'studio'
    name = Column(String, primary_key=True)
    country = Column(String)
    movies = relationship("Movie", back_populates="studio")
    
    def __init__(self, name, country):
        self.name = name
        self.country = country


class Movie(Base):
    __tablename__ = 'movie'
    imdbid = Column(String, primary_key=True)
    title = Column(String)
    year = Column(String)
    studio_name = Column(String, ForeignKey('studio.name'))
    studio = relationship('Studio', back_populates='movies')
    genres = relationship('Genre', secondary='movie_genre')

    def __init__(self, imdbid, title, year, studio_name):
        self.imdbid = imdbid
        self.title = title
        self.year = year
        self.studio_name = studio_name

class MovieGenre(Base):
    __tablename__ = 'movie_genre'
    movie_imdbid = Column(String, ForeignKey("movie.imdbid"), primary_key=True)
    genre = Column(String, ForeignKey("genre.genre"), primary_key=True)


class Genre(Base):
    __tablename__ = 'genre'
    genre = Column(String, primary_key=True)
    movies = relationship('Movie', secondary='movie_genre')

    def __init__(self, genre):
        self.genre = genre


Base.metadata.create_all(engine)

def db_fill():

    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)


    studio1 = Studio("Warner Bros", "USA")
    studio2 = Studio("Universal Pictures", "USA")
    session.add_all([studio1, studio2])

    movie1 = Movie("tt0111161", "The Shawshank Redemption", "1994", "Warner Bros")
    movie2 = Movie("tt0068646", "The Godfather", "1972", "Warner Bros")
    movie3 = Movie("tt0071562", "The Godfather: Part II", "1974", "Universal Pictures")
    movie4 = Movie("tt0468569", "The Dark Knight", "2008", "Warner Bros")
    session.add_all([movie1, movie2, movie3, movie4])

    genre1 = Genre("Drama")
    genre2 = Genre("Adventure")
    genre3 = Genre("Action")
    session.add_all([genre1, genre2, genre3])

    movie1.genres.extend([genre1, genre2])
    movie2.genres.extend([genre1, genre2])
    movie3.genres.extend([genre1, genre2])
    movie4.genres.append(genre3)

    session.commit()

def display_all_studios(sessionmaker): 
    studio = Table('studio', metadata, autoload_with=engine)
    result = connection.execute(select(studio))
    for row in result:
        print(row)
    pass
def display_movies_of_studio(sessionmaker, studio_name):
    movie = Table('movie', metadata, autoload_with=engine)
    result = connection.execute(select(movie).where(movie.c.studio_name == studio_name))
    for row in result:
        print(row)
    pass
def display_all_genres(sessionmaker):
    genre = Table('genre', metadata, autoload_with=engine)
    result = connection.execute(select(genre))
    for row in result:
        print(row)
    pass
def display_movies_of_genre(sessionmaker, genre_name): 
    movie = Table('movie', metadata, autoload_with=engine)
    movie_genre = Table('movie_genre', metadata, autoload_with=engine)
    result = connection.execute(select(movie).join(movie_genre, movie.c.imdbid == movie_genre.c.movie_imdbid).where(movie_genre.c.genre == genre_name))
    for row in result:
        print(row)
    pass
             
def main():
    while True:
        print("\nMenu:")
        print("1. Display all Studios")
        print("2. Display Movies of a Studio")
        print("3. Display all Genres")
        print("4. Display Movies of a Genre")
        print("5. Exit")
        choice = int(input("Enter your choice: "))
        if choice == 1:
            display_all_studios(session)
        elif choice == 2:
            studio_name = input("Enter Studio name: ")
            display_movies_of_studio(session, studio_name)
        elif choice == 3:
            display_all_genres(session)
        elif choice == 4:
            genre_name = input("Enter Genre name: ")
            display_movies_of_genre(session, genre_name)
        elif choice == 5:
            break
        else:
            print("Invalid choice. Try again.")

if __name__ == '__main__':
    db_fill()
    main()

