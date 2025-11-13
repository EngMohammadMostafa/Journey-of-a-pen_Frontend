import React, { useState, useEffect } from 'react'
import '../../styles/global.css'
import { useAuth } from '../../context/AuthContext'
import { useNavigate } from 'react-router-dom'
import navbarImage from '../../assets/navbarpicture.jpg'

const Navbar = ({ onToggleSidebar }) => {
  const { logout } = useAuth()
  const navigate = useNavigate()
  const [isHeroVisible, setIsHeroVisible] = useState(true)
  const [lastScrollY, setLastScrollY] = useState(0)

  useEffect(() => {
    const handleScroll = () => {
      const currentScrollY = window.scrollY
      
      // إذا كان المستخدم يمرر لأسفل ويبتعد عن الأعلى
      if (currentScrollY > lastScrollY && currentScrollY > 100) {
        setIsHeroVisible(false)
      } 
      // إذا كان المستخدم يمرر لأعلى
      else if (currentScrollY < lastScrollY) {
        setIsHeroVisible(true)
      }
      
      setLastScrollY(currentScrollY)
    }

    window.addEventListener('scroll', handleScroll, { passive: true })
    
    return () => {
      window.removeEventListener('scroll', handleScroll)
    }
  }, [lastScrollY])

  const handleLogout = async () => {
    await logout()
    navigate('./pages/Login')
  }

  return (
    <>
      <nav className="navbar">
        <div className="navbar-left">
          <div className="navbar-brand">
            <h1>DASHPORD ADMIN</h1>
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
            <div className="nav-item">
  <button 
    className="nav-icon-btn" 
    onClick={() => navigate('/dashboard')}
  >
    <span className="icon">🏠</span>
    <span className="label">العودة للوحة التحكم</span>
  </button>
</div>

            <div className="nav-item">
              <button className="nav-icon-btn" onClick={handleLogout}>
                <span className="icon">🚪</span>
                <span className="label">خروج</span>
              </button>
            </div>
          </div>
        </div>
      </nav>

      {/* ✅ الجزء المعدل للصورة الثابتة */}
      <div className={`hero-section ${isHeroVisible ? '' : 'hidden'}`}>
        <img 
          src={navbarImage} 
          alt="Dashboard Welcome" 
          className="hero-image"
        />
        <div className="hero-text">
        <h1>Welcome to the control panel</h1>
        <p>Here you can manage all your activities</p>
        </div>
      </div>
    </>
  )
}

export default Navbar