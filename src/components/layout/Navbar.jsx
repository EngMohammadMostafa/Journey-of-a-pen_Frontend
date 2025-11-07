
import React from 'react'
import './Navbar.css'
import { useAuth } from '../../context/AuthContext'
import { useNavigate } from 'react-router-dom'

const Navbar = ({ onToggleSidebar }) => {
  const { logout } = useAuth()
  const navigate = useNavigate()

  const handleLogout = async () => {
    await logout()
    navigate('./pages/Login')
  }

  return (
    <nav className="navbar">
      <div className="navbar-left">
        <div className="navbar-brand">
          <h1> DASHPORD ADMIN </h1>
          
        </div>
      </div>

      <div className="navbar-right">
        <div className="navbar-items">
          <div className="nav-item">
            <button className="nav-icon-btn">
              <span className="icon">🔔</span>
              <span className="badge">3</span>
            </button>
          </div>

          <div className="nav-item">
            <button className="nav-icon-btn">
              <span className="icon">⚙️</span>
            </button>
          </div>

          <div className="nav-item user-menu">
            <div className="user-avatar-small">👤</div>
            <div className="user-info">
              <span className="user-name">الأدمن</span>
              <span className="user-role">مدير النظام</span>
            </div>
          </div>

          {/* ✅ زر تسجيل الخروج */}
          <div className="nav-item">
            <button className="nav-icon-btn" onClick={handleLogout}>
              <span className="icon">🚪</span>
              <span className="label">خروج</span>
            </button>
          </div>
        </div>
      </div>
    </nav>
  )
}

export default Navbar
