import axios from 'axios'

const API_BASE = '/api/admin'

export const competitionsService = {
  getAllCompetitions: async (token) => {
    const res = await axios.get(`${API_BASE}/competitions`, {
      headers: { Authorization: `Bearer ${token}` }
    })
    return res.data
  },
  addCompetition: async (data, token) => {
    const res = await axios.post(`${API_BASE}/competitions`, data, {
      headers: { Authorization: `Bearer ${token}` }
    })
    return res.data
  }
}
