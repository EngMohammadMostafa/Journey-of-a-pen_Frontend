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

  //  تمت إضافته لإخفاء النافبار
  const [hideNavbar, setHideNavbar] = useState(false)

  useEffect(() => {
    const handleScroll = () => {
      const currentScrollY = window.scrollY
      
      // إذا كان المستخدم يمرر لأسفل → إخفاء النافبار والهيرو
      if (currentScrollY > lastScrollY && currentScrollY > 45) {
        setHideNavbar(true)
        setIsHeroVisible(false)
      } 
      // إذا كان المستخدم يمرر لأعلى → إظهار النافبار والهيرو
      else if (currentScrollY === 0) {
        setHideNavbar(false)
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
      {/*  إضافة كلاس hidden للنافبار */}
      <nav className={`navbar ${hideNavbar ? "hidden" : ""}`}>
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
                <span className="label">Notifications</span>

                
              </button>
            </div>

            

            <div className="nav-item user-menu">
              <div className="user-avatar-small">👤</div>
              <div className="user-info">
                <span className="user-name">Admin</span>
                <span className="user-role"> System Administator</span>
              </div>
            </div>

            <div className="nav-item">
              <button 
                className="nav-icon-btn" 
                onClick={() => navigate('/dashboard')}
              >
                <span className="icon">🏠</span>
                <span className="label"> Welcome Dashboard </span>
              </button>
            </div>

            <div className="nav-item">
              <button className="nav-icon-btn" onClick={handleLogout}>
                <span className="icon">🚪</span>
                <span className="label">Exite</span>
              </button>
            </div>
          </div>
        </div>
      </nav>

      {/* الهيرو سكشن */}
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
