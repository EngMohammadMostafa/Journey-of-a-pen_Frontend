

// src/Router.jsx
import React from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuth } from './context/AuthContext'
import Sidebar from './components/layout/Sidebar'
import Navbar from './components/layout/Navbar'
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import UsersManagement from './pages/UsersManagement'
import BooksManagement from './pages/BooksManagement'
import CompetitionsManagement from './pages/CompetitionsManagement'
import QuotesManagement from './pages/QuotesManagement'
import NotificationsManagement from './pages/NotificationsManagement'


import PaymentsManagement from './pages/PaymentsManagement'
import PointsManagement from './pages/PointsManagement'

const AppRouter = ({ sidebarCollapsed, onToggleSidebar }) => {
  const { user, isAuthenticated, loading } = useAuth() // ✅ الآن isAuthenticated موجود

  // عرض شاشة تحميل أثناء التحقق من المصادقة
  if (loading) {
    return (
      <div style={{ 
        display: 'flex', 
        justifyContent: 'center', 
        alignItems: 'center', 
        height: '100vh',
        fontSize: '1.2rem'
      }}>
        جاري التحميل...
      </div>
    )
  }

  // إذا لم يكن مسجل دخول، اعرض صفحة اللوجين فقط
  if (!isAuthenticated) {
    return (
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="*" element={<Navigate to="/login" />} />
      </Routes>
    )
  }

  // إذا كان مسجل دخول، اعرض الهيكل الكامل
  //يوجد سطر حذفته له علاقة بالسايدبار  تم حذفه كان ثاني سطر
  return (
    <div className="app-layout">
      <Sidebar collapsed={sidebarCollapsed} />


      <div className="main-container">
        <Navbar onToggleSidebar={onToggleSidebar} />
        <div className="content-area">
          
          <Routes>
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/users" element={<UsersManagement />} />
            <Route path="/books" element={<BooksManagement />} />
            <Route path="/competitions" element={<CompetitionsManagement />} />
            <Route path="/quotes" element={<QuotesManagement />} />
            <Route path="/notifications" element={<NotificationsManagement />} />
            
          
          
            <Route path="/payments" element={<PaymentsManagement />} />
            <Route path="/points" element={<PointsManagement />} />
            <Route path="/login" element={<Navigate to="/dashboard" />} />
            <Route path="/" element={<Navigate to="/dashboard" />} />
            <Route path="*" element={<Navigate to="/dashboard" />} />
          </Routes>
        </div>
      </div>
    </div>
  )
}

export default AppRouter







