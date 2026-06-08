import pickle
import streamlit as st
import requests
import pandas as pd

def fetch_poster(movie_id):
    url = f"https://api.themoviedb.org/3/movie/{movie_id}?api_key=8265bd1679663a7ea12ac168da84d2e8&language=en-US"
    data = requests.get(url).json()
    poster_path = data.get('poster_path', '')
    full_path = "https://image.tmdb.org/t/p/w500/" + poster_path if poster_path else ""
    return full_path

def recommend(movie):
    index = movies[movies['title'] == movie].index[0]
    distances = sorted(enumerate(similarity[index]), reverse=True, key=lambda x: x[1])
    recommended_movie_names = []
    recommended_movie_posters = []
    for i in distances[1:6]:
        movie_id = movies.iloc[i[0]].movie_id
        recommended_movie_posters.append(fetch_poster(movie_id))
        recommended_movie_names.append(movies.iloc[i[0]].title)
    return recommended_movie_names, recommended_movie_posters

@st.cache_data(show_spinner=False)
def load_similarity():
    with open('app/similarity.pkl', 'rb') as f:
        similarity = pickle.load(f)
    return similarity

st.set_page_config(page_title="🎬 Movie Recommender", layout="wide")
st.title('🎥 Movie Recommender System')

# Load movie list locally (make sure this path is correct)
movies = pickle.load(open('app/movie_list.pkl', 'rb'))

# Load similarity matrix locally
similarity = load_similarity()

selected_movie = st.selectbox("🎬 Type or select a movie:", movies['title'].values)

if st.button('🎯 Show Recommendations'):
    names, posters = recommend(selected_movie)
    cols = st.columns(5)
    for i in range(5):
        with cols[i]:
            if posters[i]:
                st.image(posters[i])
            else:
                st.write("No poster available")
            st.markdown(f"**{names[i]}**")
