


// src/App.jsx
import React from 'react'
import { BrowserRouter as Router } from 'react-router-dom'
import "./styles/global.css"
import { AuthProvider } from './context/AuthContext'
import AppRouter from './Router'


function App() {
  return (
    <AuthProvider>
      <Router>
        <AppRouter />
      </Router>
    </AuthProvider>
  );
}

export default App

