import { useAccount } from 'wagmi'
import { Web3Button } from '@web3modal/react'

export default function Layout() {
  const { isConnected } = useAccount()

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex-shrink-0 flex items-center">
              <h1 className="text-xl font-bold text-indigo-600">CredSoul</h1>
            </div>
            <div className="flex items-center">
              <Web3Button />
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        {isConnected ? (
          <div className="bg-white shadow sm:rounded-lg">
            <div className="px-4 py-5 sm:p-6">
              <h2 className="text-lg font-medium text-gray-900">Welcome to CredSoul</h2>
              <p className="mt-1 text-sm text-gray-500">
                Your decentralized credit scoring platform
              </p>
            </div>
          </div>
        ) : (
          <div className="text-center">
            <h2 className="mt-2 text-lg font-medium text-gray-900">
              Connect your wallet to get started
            </h2>
          </div>
        )}
      </main>
    </div>
  )
}