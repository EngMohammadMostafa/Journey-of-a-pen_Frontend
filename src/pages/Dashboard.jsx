// src/pages/Dashboard.jsx
import React from 'react'
import '../styles/global.css'
import heroImage from '../assets/navbarpicture.jpg'; // ✅ استيراد الصورة

const Dashboard = () => {
  return (
    
    <div className="hero-section">
    <img 
      src={heroImage}
      alt="مرحباً بك في لوحة التحكم" 
      className="hero-image" 
    />
    <div className="hero-text">
      <h1>Welcome to the control panel</h1>
      <p>We are happy you are back!</p>
    </div>
  </div>
 
 
  );
};

export default Dashboard